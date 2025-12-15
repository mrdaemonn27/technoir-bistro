<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // PERBAIKAN: Nama tabel harus 'menu_reservation', BUKAN 'reservations'
        Schema::create('menu_reservation', function (Blueprint $table) {
            $table->id();
            
            // Kunci Asing ke tabel reservations
            $table->foreignId('reservation_id')->constrained()->cascadeOnDelete();
            
            // Kunci Asing ke tabel menus
            $table->foreignId('menu_id')->constrained()->cascadeOnDelete();
            
            // Jumlah porsi
            $table->integer('quantity'); 
            
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('menu_reservation');
    }
};