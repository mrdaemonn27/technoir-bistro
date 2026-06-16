<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage; 

class AuthController extends Controller
{
    public function login(Request $request)
    {
        // 1. Cari user berdasarkan email
        $user = User::where('email', $request->email)->first();

        // 2. Cek apakah user ada dan passwordnya benar
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau Password salah'
            ], 401);
        }

        // 3. Buat Token (Karcis Masuk)
        $token = $user->createToken('auth_token')->plainTextToken;

        // 4. Kembalikan data ke Flutter
        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'token' => $token,
            'user' => $user
        ]);
    } 

    public function register(Request $request)
    {
        // 1. Validasi input dari Flutter
        $validator = Validator::make($request->all(), [
            'username' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 400);
        }

        // 2. Simpan user baru ke database
        $user = User::create([
            'username' => $request->username,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'is_verified' => false, // Default bawaan
            'is_admin' => false, // Default bawaan
        ]);

        // 3. Langsung buatkan Token agar otomatis Login setelah daftar
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil',
            'token' => $token,
            'user' => $user
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'username' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            // Tambahkan validasi untuk foto (avatar)
            'avatar' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', 
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 400);
        }

        $user->username = $request->username;
        $user->email = $request->email;

        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        // --- LOGIKA MENYIMPAN FOTO ---
        if ($request->hasFile('avatar')) {
            // Hapus avatar lama jika ada (agar storage tidak penuh)
            if ($user->avatar && Storage::disk('public')->exists($user->avatar)) {
                Storage::disk('public')->delete($user->avatar);
            }
            
            // Simpan foto baru ke folder storage/app/public/avatars
            $path = $request->file('avatar')->store('avatars', 'public');
            
            // Simpan path-nya ke kolom database (pastikan Anda punya kolom 'avatar' di tabel users)
            $user->avatar = $path; 
        }

        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'user' => $user
        ]);
    }

    // --- TAMBAHAN BARU: FUNGSI UNTUK STATISTIK USER ---
    public function getUserStats(Request $request)
    {
        $user = $request->user();
        
        // 1. Hitung total reservasi yang pernah dibuat user ini
        $reservationCount = \App\Models\Reservation::where('user_id', $user->id)->count();
        
        // 2. Hitung total porsi makanan (dish) yang dipesan user ini
        $reservations = \App\Models\Reservation::with('menus')->where('user_id', $user->id)->get();
        $dishOrderedCount = 0;
        
        foreach ($reservations as $reservation) {
            foreach ($reservation->menus as $menu) {
                // Menambahkan kuantitas pesanan dari tabel pivot (reservation_menu)
                // Jika tidak ada pivot quantity, default dihitung 1
                $dishOrderedCount += $menu->pivot->quantity ?? 1;
            }
        }

        return response()->json([
            'success' => true,
            'reservation_count' => $reservationCount,
            'dish_ordered_count' => $dishOrderedCount
        ]);
    }
}