<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController; 
use App\Http\Controllers\MenuController; 
use App\Http\Controllers\Admin\MenuController as AdminMenuController; 
use App\Http\Controllers\TableController;
use App\Http\Controllers\ReservationController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\Admin\DashboardController as AdminDashboardController;
use App\Http\Controllers\ProfileController;

// == RUTE PUBLIK (Bisa diakses semua orang) ==

// Halaman utama (Homepage)
Route::get('/', [HomeController::class, 'index'])->name('home'); 

// (FR-04) Melihat Menu (Publik)
Route::get('/menu', [MenuController::class, 'index'])->name('menu.index');

// (FR-05) Melihat Ketersediaan Meja (Publik)
Route::get('/tables', [TableController::class, 'index'])->name('tables.index'); 


// == RUTE PELANGGAN (Harus login) ==
Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');

    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    // Fitur Pelanggan Lainnya
    Route::resource('reservations', ReservationController::class);
    Route::resource('payments', PaymentController::class);
    Route::resource('favorites', FavoriteController::class)->only(['index', 'store', 'destroy']);
});


// == RUTE ADMIN (Harus login & 'is_admin' == true) ==
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {

    // --- PERUBAHAN BARU DI SINI ---
    // Menambahkan rute '/' di dalam grup admin.
    // Hasilnya: http://127.0.0.1:8000/admin akan membuka Dashboard Admin.
    Route::get('/', [AdminDashboardController::class, 'index'])->name('index');

    // Rute /admin/dashboard (tetap ada sebagai alternatif)
    Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('dashboard');

    // (FR-10) Admin Kelola Menu
    Route::resource('menus', AdminMenuController::class); 
});


// Rute Autentikasi (bawaan Breeze)
require __DIR__ . '/auth.php';