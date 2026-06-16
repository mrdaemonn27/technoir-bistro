<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MenuController;
use App\Http\Controllers\Api\ReservationController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\ReportController;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::get('/menus', [MenuController::class, 'index']); // Publik bisa lihat menu
Route::get('/categories', function () {
    return response()->json(['success' => true, 'data' => \App\Models\Category::all()]);
});

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::middleware('auth:sanctum')->group(function () {
    // --- RUTE UNTUK USER PELANGGAN ---
    Route::post('/reservations', [ReservationController::class, 'store']);
    Route::get('/reservations/history', [ReservationController::class, 'userHistory']); 
    Route::get('/notifications', [ReservationController::class, 'notifications']); 
    
    // Rute Profil
    Route::post('/profile/update', [AuthController::class, 'updateProfile']); 
    Route::get('/profile/stats', [AuthController::class, 'getUserStats']); // <-- TAMBAHAN BARU UNTUK STATISTIK PROFIL

    // Rute Favorit
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites/toggle', [FavoriteController::class, 'toggle']);

    // --- RUTE CRUD UNTUK ADMIN MENU ---
    Route::post('/menus', [MenuController::class, 'store']);
    Route::put('/menus/{id}', [MenuController::class, 'update']);
    Route::delete('/menus/{id}', [MenuController::class, 'destroy']);

    // --- RUTE UNTUK ADMIN RESERVASI & LAPORAN ---
    Route::get('/reservations', [ReservationController::class, 'index']); 
    Route::put('/reservations/{id}/status', [ReservationController::class, 'updateStatus']); 
    
    // RUTE LAPORAN KEUANGAN
    Route::get('/reports', [ReportController::class, 'index']); 
});