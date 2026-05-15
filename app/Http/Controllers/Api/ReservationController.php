<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Reservation;
use App\Models\Table; // <-- TAMBAHKAN IMPORT MODEL TABLE
use Illuminate\Support\Facades\Log;

class ReservationController extends Controller
{
    public function store(Request $request)
    {
        // 1. Validasi Data dari Flutter
        $request->validate([
            'reservation_date' => 'required|date',
            'reservation_time' => 'required',
            'guests' => 'required|string',
        ]);

        try {
            // 2. Ekstrak angka dari string (Misal: "2 People" menjadi angka 2)
            $guestsCount = (int) filter_var($request->guests, FILTER_SANITIZE_NUMBER_INT);
            if ($guestsCount == 0) $guestsCount = 1;

            // 3. Cari meja pertama sebagai default (Nanti admin yang mengatur meja pastinya)
            $table = Table::first();
            $tableId = $table ? $table->id : 1; // Jika ada meja ambil ID-nya, jika kosong pakai 1

            // 4. Simpan ke Database
            $reservation = Reservation::create([
                'user_id' => $request->user()->id,
                'table_id' => $tableId, 
                'reservation_date' => $request->reservation_date,
                'reservation_time' => $request->reservation_time,
                'guest_count' => $guestsCount, // <--- PERBAIKAN: Ubah 'guests' menjadi 'guest_count'
                'status' => 'Pending', 
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

    // --- TAMBAHKAN FUNGSI INI UNTUK ORDER HISTORY ---
    public function userHistory(Request $request)
    {
        try {
            // Ambil riwayat reservasi khusus untuk user yang sedang login
            // Urutkan dari yang terbaru (created_at descending)
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