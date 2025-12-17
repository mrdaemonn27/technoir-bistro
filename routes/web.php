<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController; 
use App\Http\Controllers\MenuController; 
use App\Http\Controllers\AboutController; 
use App\Http\Controllers\ContactController; // <--- TAMBAHAN: Import ContactController
use App\Http\Controllers\Admin\MenuController as AdminMenuController; 
// --- Import Controller Admin ---
use App\Http\Controllers\Admin\ReservationController as AdminReservationController;
use App\Http\Controllers\Admin\ReportController; 

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

// Halaman About
Route::get('/about', [AboutController::class, 'index'])->name('about');

// --- TAMBAHAN BARU: Halaman Contact ---
Route::get('/contact', [ContactController::class, 'index'])->name('contact');
Route::post('/contact', [ContactController::class, 'store'])->name('contact.store');


// == RUTE PELANGGAN (Harus login) ==
Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');

    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    // Rute pembayaran Xendit
    Route::get('/payments/success', [PaymentController::class, 'success'])->name('payments.success');
    Route::get('/payments/failed', [PaymentController::class, 'failed'])->name('payments.failed');

    // Fitur Pelanggan Lainnya
    Route::resource('reservations', ReservationController::class)->except(['show']);
    Route::resource('payments', PaymentController::class)->only(['create', 'store']);
    Route::resource('favorites', FavoriteController::class)->only(['index', 'store', 'destroy']);
});

// Webhook Xendit (tidak perlu login)
Route::post('/webhooks/xendit', [PaymentController::class, 'webhook'])->name('payments.webhook');


// == RUTE ADMIN (Harus login & 'is_admin' == true) ==
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {

    // Dashboard Admin
    Route::get('/', [AdminDashboardController::class, 'index'])->name('index');
    Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('dashboard');

    // (FR-10) Admin Kelola Menu
    Route::resource('menus', AdminMenuController::class); 

    // Admin Kelola Reservasi Masuk
    Route::resource('reservations', AdminReservationController::class);

    // Rute Laporan Keuangan
    Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
});


// Rute Autentikasi (bawaan Breeze)
require __DIR__ . '/auth.php';