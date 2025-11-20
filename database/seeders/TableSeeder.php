<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Table;
use Illuminate\Support\Facades\DB;

class TableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Kosongkan tabel dulu biar tidak duplikat saat re-seeding
        // Kita matikan pengecekan foreign key sebentar agar bisa truncate aman
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        Table::truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // --- Membuat Data Dummy Meja ---

        // 1. Meja Kecil (2 Orang) - Status: Tersedia
        Table::create([
            'table_number' => 'A1',
            'capacity' => 2,
            'status' => 'available',
            'location' => 'Indoor'
        ]);

        // 2. Meja Kecil (2 Orang) - Status: Terisi (Sedang ada tamu)
        Table::create([
            'table_number' => 'A2',
            'capacity' => 2,
            'status' => 'occupied',
            'location' => 'Indoor'
        ]);

        // 3. Meja Sedang (4 Orang) - Status: Tersedia
        Table::create([
            'table_number' => 'B1',
            'capacity' => 4,
            'status' => 'available',
            'location' => 'Indoor'
        ]);

        // 4. Meja Sedang (4 Orang) - Status: Sudah Direservasi
        Table::create([
            'table_number' => 'B2',
            'capacity' => 4,
            'status' => 'reserved',
            'location' => 'Indoor'
        ]);

        // 5. Meja VIP (Rooftop) - Status: Tersedia
        Table::create([
            'table_number' => 'VIP-1',
            'capacity' => 6,
            'status' => 'available',
            'location' => 'Rooftop'
        ]);

        // 6. Meja Outdoor - Status: Sedang Dibersihkan
        Table::create([
            'table_number' => 'OUT-1',
            'capacity' => 4,
            'status' => 'cleaning',
            'location' => 'Outdoor'
        ]);
    }
}