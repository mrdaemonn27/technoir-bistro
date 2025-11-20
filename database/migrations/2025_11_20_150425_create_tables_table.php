<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tables', function (Blueprint $table) {
            $table->id();
            // FR-05: Identitas Meja
            $table->string('table_number')->unique(); // Unik, tidak boleh ada 2 meja nomor "A1"
            $table->integer('capacity'); // Berapa kursi?
            
            // FR-07: Status Meja (Enum biar pilihannya pasti)
            // available = Tersedia
            // occupied = Terisi (Sedang makan)
            // reserved = Direservasi (Sudah dipesan)
            // cleaning = Dibersihkan (Pelanggan pergi, pelayan bersih-bersih)
            $table->enum('status', ['available', 'occupied', 'reserved', 'cleaning'])->default('available');
            
            $table->string('location')->default('indoor'); // Lokasi meja
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tables');
    }
};