<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\Reservation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

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

        $reservation = Reservation::findOrFail($request->reservation_id);

        // Keamanan: Pastikan yang bayar adalah pemilik reservasi
        if ($reservation->user_id !== Auth::id()) {
            abort(403, 'Unauthorized action.');
        }

        // Cek jika sudah pernah bayar (mencegah double payment untuk satu reservasi)
        if ($reservation->payment) {
            return redirect()->route('reservations.index')->with('info', 'Pembayaran untuk reservasi ini sudah ada.');
        }

        return view('payments.create', compact('reservation'));
    }

    /**
     * Menyimpan data pembayaran & file upload.
     */
    public function store(Request $request)
    {
        $request->validate([
            'reservation_id' => 'required|exists:reservations,id',
            'amount' => 'required|numeric|min:1',
            'proof_of_payment' => 'required|image|mimes:jpeg,png,jpg|max:2048', // Maks 2MB
        ]);

        $reservation = Reservation::findOrFail($request->reservation_id);

        // Upload File
        if ($request->hasFile('proof_of_payment')) {
            $path = $request->file('proof_of_payment')->store('payments', 'public');
        } else {
            return back()->with('error', 'Gagal mengupload file.');
        }

        // Simpan ke Database
        Payment::create([
            'reservation_id' => $reservation->id,
            'amount' => $request->amount,
            'payment_method' => 'bank_transfer',
            'payment_status' => 'pending',
            'proof_of_payment' => $path,
            'payment_date' => now(),
        ]);

        return redirect()->route('reservations.index')
                         ->with('success', 'Bukti pembayaran berhasil dikirim! Menunggu verifikasi admin.');
    }
}