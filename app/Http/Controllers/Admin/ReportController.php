<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Payment; // Pastikan Anda memiliki model Payment
use Illuminate\Http\Request;
use Carbon\Carbon;

class ReportController extends Controller
{
    public function index()
    {
        // 1. Hitung Statistik Pendapatan
        // Asumsi: Table 'payments' punya kolom 'amount' dan 'created_at'
        
        $today = Carbon::today();
        $thisMonth = Carbon::now()->month;
        $thisYear = Carbon::now()->year;

        // Pendapatan Hari Ini
        $dailyRevenue = Payment::whereDate('created_at', $today)->sum('amount');

        // Pendapatan Bulan Ini
        $monthlyRevenue = Payment::whereMonth('created_at', $thisMonth)
                                 ->whereYear('created_at', $thisYear)
                                 ->sum('amount');

        // Total Pendapatan Keseluruhan
        $totalRevenue = Payment::sum('amount');

        // 2. Ambil Data Transaksi Terbaru
        // Menggunakan pagination untuk tabel
        $recentPayments = Payment::with('reservation.user') // Eager load relasi jika ada
                                 ->latest()
                                 ->paginate(10);

        return view('admin.reports.index', compact(
            'dailyRevenue', 
            'monthlyRevenue', 
            'totalRevenue', 
            'recentPayments'
        ));
    }
}