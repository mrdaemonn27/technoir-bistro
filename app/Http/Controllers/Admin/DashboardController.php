<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use App\Models\Payment;
use App\Models\Reservation;

class DashboardController extends Controller
{
    /**
     * Display the admin dashboard.
     */
    public function index()
    {
        $stats = [
            'menus' => Menu::count(),
            'availableMenus' => Menu::where('availability', true)->count(),
            'reservations' => Reservation::count(),
            'pendingReservations' => Reservation::where('status', 'pending')->count(),
            'revenue' => Payment::sum('amount'),
        ];

        $recentReservations = Reservation::with(['user', 'table'])
            ->latest()
            ->take(5)
            ->get();

        return view('admin.dashboard', compact('stats', 'recentReservations'));
    }
}