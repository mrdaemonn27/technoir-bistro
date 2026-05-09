<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

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
    // ^^^ Perhatikan, kurung kurawal di sini HANYA menutup fungsi login, bukan class!

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
}