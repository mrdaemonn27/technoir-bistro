<?php

namespace App\Http\Controllers;

use App\Models\Menu;

class MenuController extends Controller
{
    /**
     * Menampilkan daftar menu untuk publik.
     */
    public function index()
    {
        // (FR-04) Ambil semua menu dari database yang 'availability' nya true (Tersedia)
        // Gunakan latest() agar menu terbaru muncul di awal
        $menus = Menu::where('availability', true)->latest()->get();

        // Kirim data $menus ke view 'menu.index'
        // Pastikan file view ada di: resources/views/menu/index.blade.php
        return view('menu.index', compact('menus'));
    }
}