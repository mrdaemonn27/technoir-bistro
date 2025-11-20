<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class MenuController extends Controller
{
    /**
     * Menampilkan daftar menu (Admin View).
     */
    public function index()
    {
        $menus = Menu::with('category')->latest()->get();
        return view('admin.menus.index', compact('menus'));
    }

    /**
     * Menampilkan form tambah menu.
     */
    public function create()
    {
        $categories = Category::all();
        return view('admin.menus.create', compact('categories'));
    }

    /**
     * Menyimpan menu baru beserta gambar.
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'category_id' => 'required|exists:categories,id',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', // Max 2MB
            'availability' => 'boolean',
        ]);

        $data = $request->all();

        // LOGIKA UPLOAD GAMBAR
        if ($request->hasFile('image')) {
            // Simpan ke folder 'public/menus'
            $path = $request->file('image')->store('menus', 'public');
            $data['image'] = $path;
        }

        // Set default availability jika tidak ada
        $data['availability'] = $request->has('availability');

        Menu::create($data);

        return redirect()->route('admin.menus.index')->with('success', 'Menu berhasil ditambahkan!');
    }

    /**
     * Menampilkan form edit menu.
     */
    public function edit(Menu $menu)
    {
        $categories = Category::all();
        return view('admin.menus.edit', compact('menu', 'categories'));
    }

    /**
     * Mengupdate menu dan gambar.
     */
    public function update(Request $request, Menu $menu)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'category_id' => 'required|exists:categories,id',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $data = $request->all();

        // LOGIKA UPDATE GAMBAR
        if ($request->hasFile('image')) {
            // 1. Hapus gambar lama jika ada (dan bukan URL internet)
            if ($menu->image && !filter_var($menu->image, FILTER_VALIDATE_URL)) {
                Storage::disk('public')->delete($menu->image);
            }

            // 2. Upload gambar baru
            $path = $request->file('image')->store('menus', 'public');
            $data['image'] = $path;
        }

        $data['availability'] = $request->has('availability'); // Checkbox handling

        $menu->update($data);

        return redirect()->route('admin.menus.index')->with('success', 'Menu berhasil diperbarui!');
    }

    /**
     * Menghapus menu dan gambarnya.
     */
    public function destroy(Menu $menu)
    {
        // Hapus gambar fisik
        if ($menu->image && !filter_var($menu->image, FILTER_VALIDATE_URL)) {
            Storage::disk('public')->delete($menu->image);
        }

        $menu->delete();

        return redirect()->route('admin.menus.index')->with('success', 'Menu berhasil dihapus.');
    }
}