<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AboutController extends Controller
{
    /**
     * Menampilkan halaman About Us.
     */
    public function index()
    {
        return view('about');
    }
}