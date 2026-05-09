<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Menu;

class MenuController extends Controller
{
    public function index()
    {
        // Ambil semua menu yang tersedia beserta nama kategorinya
        $menus = Menu::with('category')->where('availability', true)->get();
        
        return response()->json([
            'success' => true,
            'data' => $menus
        ]);
    }
}