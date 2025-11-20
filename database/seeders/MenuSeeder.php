<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\Menu;
use Illuminate\Support\Facades\DB;

class MenuSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Kosongkan tabel dulu (opsional tapi disarankan)
        // Nonaktifkan pengecekan foreign key agar bisa TRUNCATE
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        Category::truncate();
        Menu::truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // 2. Buat Kategori
        $catMakanan = Category::create([
            'name' => 'Makanan Utama',
            'description' => 'Hidangan utama yang mengenyangkan.'
        ]);

        $catMinuman = Category::create([
            'name' => 'Minuman',
            'description' => 'Minuman segar dan nikmat.'
        ]);

        // 3. Buat Menu dan hubungkan ke Kategori
        Menu::create([
            'name' => 'Nasi Goreng Technoir',
            'description' => 'Nasi goreng spesial dengan bumbu rahasia.',
            'price' => 35000,
            'category_id' => $catMakanan->id, // <-- Dihubungkan ke ID Makanan
            'availability' => true
        ]);

        Menu::create([
            'name' => 'Cyberpunk Chilled Tea',
            'description' => 'Es teh leci dengan sentuhan neon.',
            'price' => 15000,
            'category_id' => $catMinuman->id, // <-- Dihubungkan ke ID Minuman
            'availability' => true
        ]);
        
        Menu::create([
            'name' => 'Spaghetti Carbonara',
            'description' => 'Spaghetti creamy dengan smoked beef.',
            'price' => 45000,
            'category_id' => $catMakanan->id, // <-- Dihubungkan ke ID Makanan
            'availability' => true
        ]);
    }
}