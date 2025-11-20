<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\MenuController;
use App\Http\Controllers\ReservationController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\Admin\DashboardController as AdminDashboardController;
use App\Http\Controllers\ProfileController;

// == RUTE PUBLIK (Bisa diakses semua orang) ==
// (FR-04) Melihat Menu
Route::get('/', [MenuController::class, 'index'])->name('home');
Route::get('/menu', [MenuController::class, 'index'])->name('menu.index');


// == RUTE PELANGGAN (Harus login) ==
Route::middleware(['auth', 'verified'])->group(function () {
    // Dashboard Pelanggan
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');

    // Profile (bawaan Breeze)
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    // (FR-01, FR-05, FR-08) Kelola Reservasi
    Route::resource('reservations', ReservationController::class);

    // (FR-02) Pembayaran
    Route::resource('payments', PaymentController::class);

    // (FR-03) Simpan Pesanan Favorit
    Route::resource('favorites', FavoriteController::class)->only(['index', 'store', 'destroy']);
});


// == RUTE ADMIN (Harus login & 'is_admin' == true) ==
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {

    Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('dashboard');

    // (FR-10) Admin Kelola Menu
    // Kita gunakan MenuController yang sama, tapi dengan prefix 'admin'
    Route::resource('menu', MenuController::class)->except(['index', 'show']);

    // (FR-09) Pengecekan Laporan
    // (Tambahkan method 'reports' di AdminDashboardController Anda)
    // Route::get('/reports', [AdminDashboardController::class, 'reports'])->name('reports');
});


// Rute Autentikasi (bawaan Breeze)
require __DIR__ . '/auth.php';
