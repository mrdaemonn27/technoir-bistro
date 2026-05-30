<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Reservation;
use Carbon\Carbon;

class ReportController extends Controller
{
    public function index()
    {
        try {
            // Hanya hitung reservasi yang sudah berstatus "Completed" (Selesai/Dibayar)
            $completedReservations = Reservation::with('user')
                                        ->where('status', 'Completed')
                                        ->orderBy('updated_at', 'desc')
                                        ->get();

            // Total Keseluruhan Pendapatan
            $totalRevenue = $completedReservations->sum('total_price');

            // Total Pendapatan Hari Ini
            $todayRevenue = Reservation::where('status', 'Completed')
                                ->whereDate('updated_at', Carbon::today())
                                ->sum('total_price');

            // Total Transaksi Selesai
            $totalTransactions = $completedReservations->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'total_revenue' => $totalRevenue,
                    'today_revenue' => $todayRevenue,
                    'total_transactions' => $totalTransactions,
                    'recent_transactions' => $completedReservations->take(10) // Ambil 10 transaksi terakhir untuk list
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat laporan: ' . $e->getMessage()
            ], 500);
        }
    }
}