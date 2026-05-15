<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Favorite;
use App\Models\Menu;

class FavoriteController extends Controller
{
    // Mengambil daftar menu favorit user
    public function index(Request $request)
    {
        // Ambil favorite milik user yang sedang login beserta data menu dan kategorinya
        $favorites = Favorite::with(['menu.category'])
            ->where('user_id', $request->user()->id)
            ->get()
            ->pluck('menu'); // Hanya ambil data menu-nya saja

        return response()->json([
            'success' => true,
            'data' => $favorites
        ]);
    }

    // Menambah atau menghapus menu favorit (Toggle)
    public function toggle(Request $request)
    {
        $request->validate([
            'menu_id' => 'required|exists:menus,id'
        ]);

        $userId = $request->user()->id;
        $menuId = $request->menu_id;

        // Cek apakah sudah ada di favorit
        $favorite = Favorite::where('user_id', $userId)
            ->where('menu_id', $menuId)
            ->first();

        if ($favorite) {
            // Jika sudah ada, hapus (Unfavorite)
            $favorite->delete();
            $message = 'Dihapus dari favorit';
            $isFavorited = false;
        } else {
            // Jika belum ada, tambahkan (Favorite)
            Favorite::create([
                'user_id' => $userId,
                'menu_id' => $menuId
            ]);
            $message = 'Ditambahkan ke favorit';
            $isFavorited = true;
        }

        return response()->json([
            'success' => true,
            'message' => $message,
            'is_favorited' => $isFavorited
        ]);
    }
}