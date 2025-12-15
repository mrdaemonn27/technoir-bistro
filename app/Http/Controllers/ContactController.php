<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ContactController extends Controller
{
    /**
     * Menampilkan halaman Contact Us.
     */
    public function index()
    {
        return view('contact');
    }

   
    public function store(Request $request)
    {
        // Validasi dan logika kirim email bisa ditambahkan di sini nanti
        $request->validate([
            'name' => 'required|string',
            'email' => 'required|email',
            'message' => 'required|string',
        ]);

        return back()->with('success', 'Pesan Anda telah terkirim! Kami akan segera menghubungi Anda.');
    }
}