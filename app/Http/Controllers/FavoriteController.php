<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use App\Models\Menu;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $favorites = Favorite::with('menu')
            ->where('user_id', Auth::id())
            ->latest()
            ->get();

        return view('favorites.index', compact('favorites'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'menu_id' => 'required|exists:menus,id',
        ]);

        $userId = Auth::id();

        // Toggle favorite: jika sudah ada, hapus; jika belum, buat
        $existing = Favorite::where('user_id', $userId)
            ->where('menu_id', $data['menu_id'])
            ->first();

        if ($existing) {
            $existing->delete();
            return back()->with('success', 'Menu dihapus dari favorit.');
        }

        Favorite::create([
            'user_id' => $userId,
            'menu_id' => $data['menu_id'],
        ]);

        return back()->with('success', 'Menu ditambahkan ke favorit.');
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $favorite = Favorite::where('id', $id)
            ->where('user_id', Auth::id())
            ->firstOrFail();

        $favorite->delete();

        return back()->with('success', 'Menu dihapus dari favorit.');
    }
}
