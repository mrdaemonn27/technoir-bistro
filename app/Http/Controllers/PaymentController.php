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
        if (!$request->has('reservation_id')) {
            return redirect()->route('reservations.index')->with('error', 'Reservasi tidak ditemukan.');
        }

        $reservation = Reservation::with(['user', 'table', 'menus'])->findOrFail($request->reservation_id);

        if (!$reservation->relationLoaded('user')) {
            $reservation->load('user');
        }

        if ($reservation->user_id !== Auth::id()) {
            abort(403, 'Unauthorized action.');
        }

        if ($reservation->payment) {
            return redirect()->route('reservations.index')->with('info', 'Pembayaran untuk reservasi ini sudah ada.');
        }
        
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
        // 1. Validasi Input (Tambahkan batas maksimal)
        $request->validate([
            'reservation_id' => 'required|exists:reservations,id',
            // Tambahkan max:50000000 (Maksimal 50 Juta) agar database tidak crash
            'amount' => 'required|numeric|min:50000|max:50000000', 
        ], [
            'amount.required' => 'Jumlah pembayaran tidak boleh kosong! Silakan ketik nominal (contoh: 50000).',
            'amount.min' => 'Minimum pembayaran adalah Rp 50.000',
            'amount.max' => 'Maksimum pembayaran dalam satu transaksi adalah Rp 50.000.000',
        ]);

        $reservation = Reservation::findOrFail($request->reservation_id);
        $reservation->load('menus');

        if ($reservation->user_id !== Auth::id()) {
            abort(403, 'Unauthorized action.');
        }

        if ($reservation->payment) {
            return redirect()->route('reservations.index')->with('info', 'Pembayaran untuk reservasi ini sudah ada.');
        }

        // 2. Ambil Kunci Xendit (Dengan Fallback agar tidak diam saat error)
        $secretKey = config('services.xendit.secret_key', env('XENDIT_SECRET_KEY'));
        
        // Peringatan jika belum ditaruh di .env
        if (empty($secretKey)) {
            return back()->with('error', 'GAGAL: Kunci Rahasia Xendit (XENDIT_SECRET_KEY) belum ditambahkan di file .env Laravel Anda!');
        }

        $menuTotal = 0;
        foreach ($reservation->menus as $menu) {
            $menuTotal += $menu->price * $menu->pivot->quantity;
        }

        $finalAmount = $request->amount; 
        $externalId = 'reservation-' . $reservation->id . '-' . Str::random(10);

        $payload = [
            'external_id' => $externalId,
            'amount' => (int) $finalAmount,
            'payer_email' => Auth::user()->email ?? 'customer@technoir.com',
            'description' => 'Pembayaran reservasi #' . $reservation->id . ($menuTotal > 0 ? ' (Termasuk menu)' : ''),
            'success_redirect_url' => route('reservations.index'), // Arahkan ke riwayat
            'failure_redirect_url' => route('reservations.index'),
        ];

        $httpClient = Http::withBasicAuth($secretKey, '')->acceptJson();

        if (app()->environment(['local', 'testing'])) {
            $httpClient = $httpClient->withoutVerifying();
        }

        $response = $httpClient->post('https://api.xendit.co/v2/invoices', $payload);

        // 3. Tangani Error API Xendit agar terlihat di layar
        if (!$response->successful()) {
            Log::warning('Xendit invoice create failed', [
                'reservation_id' => $reservation->id,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            // Menampilkan alasan asli penolakan dari Xendit di UI
            $errorMsg = $response->json('message', 'API Error');
            return back()->with('error', 'Gagal menghubungkan ke Xendit! Alasan: ' . $errorMsg);
        }

        $invoice = $response->json();

        // 4. Simpan Data Pembayaran ke DB
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

        // 5. Lempar ke Halaman Xendit
        return redirect()->away($payment->invoice_url);
    }

    public function success(Request $request)
    {
        return redirect()->route('reservations.index')->with('success', 'Pembayaran berhasil diproses. Kami akan memverifikasi statusnya.');
    }

    public function failed(Request $request)
    {
        return redirect()->route('reservations.index')->with('error', 'Pembayaran dibatalkan atau gagal. Silakan coba lagi.');
    }

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