<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Reservation;
use App\Models\Table;
use App\Enums\TableStatus;
use Illuminate\Http\Request;

class ReservationController extends Controller
{
    /**
     * Menampilkan daftar semua reservasi masuk.
     */
    public function index()
    {
        // Ambil data reservasi terbaru beserta relasi user dan table
        // Menggunakan pagination agar halaman tidak berat jika data banyak
        $reservations = Reservation::with(['user', 'table'])->latest()->paginate(10);

        return view('admin.reservations.index', compact('reservations'));
    }

    /**
     * (Opsional) Menampilkan form edit status reservasi.
     * Jika Anda ingin mengubah status langsung di index, method ini bisa dilewati.
     */
    public function edit(Reservation $reservation)
    {
        return view('admin.reservations.edit', compact('reservation'));
    }

    /**
     * Memperbarui status reservasi (Misal: Konfirmasi atau Selesai).
     */
    public function update(Request $request, Reservation $reservation)
    {
        // Validasi input status (sesuaikan dengan enum/string yang Anda pakai)
        $validated = $request->validate([
            'status' => 'required|in:pending,confirmed,completed,cancelled',
        ]);

        $reservation->update($validated);

        // Opsional: Jika status 'completed', meja bisa otomatis diset 'available' lagi
        // if ($request->status == 'completed' || $request->status == 'cancelled') {
        //     $reservation->table->update(['status' => TableStatus::Available]);
        // }

        return back()->with('success', 'Status reservasi berhasil diperbarui.');
    }

    /**
     * Menghapus data reservasi.
     */
    public function destroy(Reservation $reservation)
    {
        $reservation->delete();

        return back()->with('warning', 'Reservasi berhasil dihapus.');
    }
}