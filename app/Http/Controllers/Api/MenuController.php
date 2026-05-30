<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Menu;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class MenuController extends Controller
{
    // 1. MENGAMBIL SEMUA MENU (READ)
    public function index()
    {
        $menus = Menu::with('category')->orderBy('created_at', 'desc')->get();
        
        return response()->json([
            'success' => true,
            'data' => $menus
        ]);
    }

    // 2. MENAMBAH MENU BARU (CREATE)
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'price' => 'required|numeric',
            'category_id' => 'nullable|exists:categories,id',
            'description' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', // Validasi gambar
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 400);
        }

        $imagePath = null;
        if ($request->hasFile('image')) {
            // Simpan gambar ke storage/app/public/menus
            $imagePath = $request->file('image')->store('menus', 'public');
        }

        $menu = Menu::create([
            'name' => $request->name,
            'price' => $request->price,
            'category_id' => $request->category_id,
            'description' => $request->description,
            'image' => $imagePath,
            'availability' => true,
        ]);

        return response()->json(['success' => true, 'message' => 'Menu berhasil ditambahkan', 'data' => $menu], 201);
    }

    // 3. MENGEDIT MENU (UPDATE)
    public function update(Request $request, $id)
    {
        $menu = Menu::find($id);

        if (!$menu) {
            return response()->json(['success' => false, 'message' => 'Menu tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'price' => 'required|numeric',
            'category_id' => 'nullable|exists:categories,id',
            'description' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 400);
        }

        // Jika admin mengupload gambar baru
        if ($request->hasFile('image')) {
            // Hapus gambar lama agar storage tidak penuh
            if ($menu->image && Storage::disk('public')->exists($menu->image)) {
                Storage::disk('public')->delete($menu->image);
            }
            // Simpan gambar baru
            $menu->image = $request->file('image')->store('menus', 'public');
        }

        $menu->name = $request->name;
        $menu->price = $request->price;
        $menu->category_id = $request->category_id;
        $menu->description = $request->description;
        $menu->save();

        return response()->json(['success' => true, 'message' => 'Menu berhasil diperbarui', 'data' => $menu]);
    }

    // 4. MENGHAPUS MENU (DELETE)
    public function destroy($id)
    {
        $menu = Menu::find($id);

        if (!$menu) {
            return response()->json(['success' => false, 'message' => 'Menu tidak ditemukan'], 404);
        }

        // Hapus gambar dari folder public jika ada
        if ($menu->image && Storage::disk('public')->exists($menu->image)) {
            Storage::disk('public')->delete($menu->image);
        }

        // Hapus data dari database
        $menu->delete();

        return response()->json(['success' => true, 'message' => 'Menu berhasil dihapus']);
    }
}