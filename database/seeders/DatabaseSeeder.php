<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Panggil seeder Menu dan Meja (PENTING: Agar menu & meja muncul)
        $this->call([
            MenuSeeder::class,
            TableSeeder::class,
        ]);

        // 2. Buat User Test (Admin)
        User::factory()->create([
            // PERBAIKAN UTAMA: Ganti 'name' menjadi 'username'
            'username' => 'Test User', 
            
            'email' => 'test@example.com',
            'is_admin' => true,
            'is_verified' => true,
        ]);
    }
}