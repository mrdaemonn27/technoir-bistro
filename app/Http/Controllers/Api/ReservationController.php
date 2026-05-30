<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Reservation;
use App\Models\Table; // <-- IMPORT MODEL TABLE
use Illuminate\Support\Facades\Log;

class ReservationController extends Controller
{
    // ========================================================
    // 1. FUNGSI UNTUK ADMIN: MELIHAT SEMUA RESERVASI
    // ========================================================
    public function index()
    {
        try {
            // Ambil semua reservasi beserta data user (pelanggan)
            // Urutkan dari yang terbaru
            $reservations = Reservation::with(['user', 'table'])
                                     ->orderBy('created_at', 'desc')
                                     ->get();

            return response()->json([
                'success' => true,
                'data' => $reservations
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat daftar reservasi: ' . $e->getMessage()
            ], 500);
        }
    }

    // ========================================================
    // 2. FUNGSI UNTUK ADMIN: MENGUBAH STATUS RESERVASI
    // ========================================================
    public function updateStatus(Request $request, $id)
    {
        // Validasi input status yang diperbolehkan
        $request->validate([
            'status' => 'required|string|in:Pending,Confirmed,Completed,Cancelled'
        ]);

        try {
            $reservation = Reservation::find($id);

            if (!$reservation) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data reservasi tidak ditemukan'
                ], 404);
            }

            // Ubah status dan simpan
            $reservation->status = $request->status;
            $reservation->save();

            return response()->json([
                'success' => true,
                'message' => 'Status berhasil diubah menjadi ' . $request->status,
                'data' => $reservation
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui status: ' . $e->getMessage()
            ], 500);
        }
    }

    // ========================================================
    // 3. FUNGSI UNTUK USER: MEMBUAT RESERVASI BARU
    // ========================================================
    public function store(Request $request)
    {
        // Validasi Data dari Flutter
        $request->validate([
            'reservation_date' => 'required|date',
            'reservation_time' => 'required',
            'guests' => 'required|string',
        ]);

        try {
            // Ekstrak angka dari string (Misal: "2 People" menjadi angka 2)
            $guestsCount = (int) filter_var($request->guests, FILTER_SANITIZE_NUMBER_INT);
            if ($guestsCount == 0) $guestsCount = 1;

            // Cari meja pertama sebagai default
            $table = Table::first();
            $tableId = $table ? $table->id : 1; 

            // Simpan ke Database, ambil note jika ada
            $reservation = Reservation::create([
                'user_id' => $request->user()->id,
                'table_id' => $tableId, 
                'reservation_date' => $request->reservation_date,
                'reservation_time' => $request->reservation_time,
                'guest_count' => $guestsCount, 
                'notes' => $request->notes, // Simpan notes (opsional)
                'status' => 'Pending', 
                'total_price' => $request->total_price ?? 0, // Simpan total harga (opsional)
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Reservasi berhasil dibuat',
                'data' => $reservation
            ], 201);

        } catch (\Exception $e) {
            Log::error('Error Booking API: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal booking: ' . $e->getMessage()
            ], 500);
        }
    }

    // ========================================================
    // 4. FUNGSI UNTUK USER: MELIHAT RIWAYAT RESERVASI SENDIRI
    // ========================================================
    public function userHistory(Request $request)
    {
        try {
            // Ambil riwayat reservasi khusus untuk user yang sedang login
            $reservations = Reservation::where('user_id', $request->user()->id)
                                     ->orderBy('created_at', 'desc')
                                     ->get();

            return response()->json([
                'success' => true,
                'data' => $reservations
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat riwayat: ' . $e->getMessage()
            ], 500);
        }
    }
}