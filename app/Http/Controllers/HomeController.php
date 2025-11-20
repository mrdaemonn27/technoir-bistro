<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Menu;

class HomeController extends Controller
{
    /**
     * Menampilkan halaman utama (Homepage)
     */
    public function index()
    {
        // Ambil 3 menu pertama yang tersedia untuk ditampilkan di bagian "Menu Terfavorit"
        $featuredMenus = Menu::with('category')->where('availability', true)->take(3)->get();

        return view('home', compact('featuredMenus'));
    }
}