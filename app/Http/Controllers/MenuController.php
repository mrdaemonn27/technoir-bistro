<?php

// app/Http/Controllers/MenuController.php
namespace App\Http\Controllers;

use App\Models\Menu; // Import model Menu
use Illuminate\Http\Request;

class MenuController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // (FR-04) Ambil semua menu yang 'availability' nya true
        $menus = Menu::where('availability', true)->get();

        // Kirim data $menus ke view 'menu.index'
        return view('menu.index', ['menus' => $menus]);
    }

    // ... (method create, store, edit, update, destroy lainnya akan diisi nanti)
}