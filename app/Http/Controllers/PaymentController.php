<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\Reservation;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class PaymentController extends Controller
{
    /**
     * Menampilkan form pembayaran (FR-02).
     */
    public function create(Request $request)
    {
        // Pastikan ada reservation_id di URL
        if (!$request->has('reservation_id')) {
            return redirect()->route('reservations.index')->with('error', 'Reservasi tidak ditemukan.');
        }

        $reservation = Reservation::with(['user', 'table', 'menus'])->findOrFail($request->reservation_id);

        // Pastikan relasi user ter-load
        if (!$reservation->relationLoaded('user')) {
            $reservation->load('user');
        }

        // Keamanan: Pastikan yang bayar adalah pemilik reservasi
        if ($reservation->user_id !== Auth::id()) {
            abort(403, 'Unauthorized action.');
        }

        // Cek jika sudah pernah bayar (mencegah double payment untuk satu reservasi)
        if ($reservation->payment) {
            return redirect()->route('reservations.index')->with('info', 'Pembayaran untuk reservasi ini sudah ada.');
        }
        
        // Hitung total dari menu yang dipilih
        $menuTotal = 0;
        foreach ($reservation->menus as $menu) {
            $menuTotal += $menu->price * $menu->pivot->quantity;
        }

        return view('payments.create', compact('reservation', 'menuTotal'));
    }

    /**
     * Membuat invoice Xendit Sandbox dan redirect ke halaman pembayaran.
     */
    public function store(Request $request)
    {
        $request->validate([
            'reservation_id' => 'required|exists:reservations,id',
            'amount' => 'required|numeric|min:1',
        ]);

        $reservation = Reservation::findOrFail($request->reservation_id);
        
        // Load menu untuk menghitung total
        $reservation->load('menus');

        // Keamanan: Pastikan yang bayar adalah pemilik reservasi
        if ($reservation->user_id !== Auth::id()) {
            abort(403, 'Unauthorized action.');
        }

        // Cegah invoice ganda
        if ($reservation->payment) {
            return redirect()->route('reservations.index')->with('info', 'Pembayaran untuk reservasi ini sudah ada.');
        }

        // Hitung total dari menu yang dipilih (jika ada)
        $menuTotal = 0;
        foreach ($reservation->menus as $menu) {
            $menuTotal += $menu->price * $menu->pivot->quantity;
        }

        // Gunakan total menu jika ada, jika tidak gunakan amount dari request
        $finalAmount = $menuTotal > 0 ? $menuTotal : $request->amount;

        $externalId = 'reservation-' . $reservation->id . '-' . Str::random(10);

        $payload = [
            'external_id' => $externalId,
            'amount' => (int) $finalAmount,
            'payer_email' => Auth::user()->email,
            'description' => 'Pembayaran reservasi #' . $reservation->id . ($menuTotal > 0 ? ' (Termasuk menu)' : ''),
            'success_redirect_url' => route('payments.success', ['reservation_id' => $reservation->id]),
            'failure_redirect_url' => route('payments.failed', ['reservation_id' => $reservation->id]),
        ];

        $httpClient = Http::withBasicAuth(config('services.xendit.secret_key', env('XENDIT_SECRET_KEY')), '')
            ->acceptJson();

        // Disable SSL verification untuk development (Windows local)
        if (app()->environment(['local', 'testing'])) {
            $httpClient = $httpClient->withoutVerifying();
        }

        $response = $httpClient->post('https://api.xendit.co/v2/invoices', $payload);

        if (!$response->successful()) {
            Log::warning('Xendit invoice create failed', [
                'reservation_id' => $reservation->id,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return back()->with('error', 'Gagal membuat invoice. Silakan coba lagi atau hubungi admin.');
        }

        $invoice = $response->json();

        // Simpan ke Database
        $payment = Payment::create([
            'reservation_id' => $reservation->id,
            'amount' => $finalAmount,
            'payment_method' => 'xendit',
            'payment_status' => 'pending',
            'proof_of_payment' => $invoice['invoice_url'] ?? 'xendit',
            'payment_date' => now(),
            'xendit_invoice_id' => $invoice['id'] ?? null,
            'external_id' => $invoice['external_id'] ?? $externalId,
            'invoice_url' => $invoice['invoice_url'] ?? null,
            'xendit_status' => $invoice['status'] ?? 'PENDING',
        ]);

        return redirect()->away($payment->invoice_url)
                         ->with('info', 'Silakan lanjutkan pembayaran melalui Xendit.');
    }

    /**
     * Redirect sukses setelah user menyelesaikan pembayaran di Xendit.
     */
    public function success(Request $request)
    {
        return redirect()->route('reservations.index')
                         ->with('success', 'Pembayaran berhasil diproses. Kami akan memverifikasi statusnya.');
    }

    /**
     * Redirect gagal/ditutup dari Xendit.
     */
    public function failed(Request $request)
    {
        return redirect()->route('reservations.index')
                         ->with('error', 'Pembayaran dibatalkan atau gagal. Silakan coba lagi.');
    }

    /**
     * Webhook listener dari Xendit (gunakan token di header x-callback-token).
     */
    public function webhook(Request $request)
    {
        $callbackToken = $request->header('x-callback-token');
        $expectedToken = config('services.xendit.webhook_token', env('XENDIT_WEBHOOK_TOKEN'));

        if (!$expectedToken || $callbackToken !== $expectedToken) {
            return response()->json(['message' => 'Invalid token'], 401);
        }

        $invoiceId = $request->get('id');
        $externalId = $request->get('external_id');
        $status = strtoupper($request->get('status', ''));

        $payment = Payment::where('xendit_invoice_id', $invoiceId)
                          ->orWhere('external_id', $externalId)
                          ->first();

        if (!$payment) {
            Log::warning('Xendit webhook: payment not found', [
                'xendit_invoice_id' => $invoiceId,
                'external_id' => $externalId,
            ]);
            return response()->json(['message' => 'Payment not found'], 404);
        }

        $mappedStatus = match ($status) {
            'PAID', 'SETTLED' => 'verified',
            'EXPIRED', 'CANCELED' => 'rejected',
            default => 'pending',
        };

        $payment->payment_status = $mappedStatus;
        $payment->xendit_status = $status;
        $payment->paid_at = $request->has('paid_at')
            ? Carbon::parse($request->get('paid_at'))
            : now();
        $payment->payment_date = $payment->paid_at ?? now();
        $payment->save();

        return response()->json(['message' => 'ok']);
    }
}