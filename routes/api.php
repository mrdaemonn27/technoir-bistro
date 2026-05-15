<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MenuController;
use App\Http\Controllers\Api\ReservationController;
use App\Http\Controllers\Api\FavoriteController; // <-- TAMBAHKAN IMPORT INI

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::get('/menus', [MenuController::class, 'index']);

// Rute untuk mendapatkan data user yang sedang login (bawaan Laravel)
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Menggunakan middleware auth:sanctum agar terlindungi token
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/reservations', [ReservationController::class, 'store']);
    Route::get('/reservations/history', [ReservationController::class, 'userHistory']); 
    Route::post('/profile/update', [AuthController::class, 'updateProfile']); 

    // --- RUTE FAVORIT ---
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites/toggle', [FavoriteController::class, 'toggle']);
});