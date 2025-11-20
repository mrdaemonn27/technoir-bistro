<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Table; // <-- Jangan lupa import Model Table

class TableController extends Controller
{
    /**
     * Menampilkan daftar meja dan statusnya (FR-05).
     */
    public function index()
    {
        // Ambil semua meja, urutkan berdasarkan nomor meja (A1, A2, B1...)
        $tables = Table::orderBy('table_number')->get();

        // Kirim data ke view 'tables/index.blade.php'
        return view('tables.index', [
            'tables' => $tables
        ]);
    }
}