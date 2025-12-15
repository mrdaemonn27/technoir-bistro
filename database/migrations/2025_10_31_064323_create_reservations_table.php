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
        Schema::create('reservations', function (Blueprint $table) {
            $table->id();
            
            // Relasi ke User
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            
            // Relasi ke Tables
            // Pastikan tabel 'tables' sudah ada sebelum migrasi ini berjalan
            $table->foreignId('table_id')->constrained('tables')->onDelete('cascade');
            
            // Data reservasi
            $table->dateTime('reservation_date');
            $table->integer('guest_count');
            $table->text('notes')->nullable();
            
            // Status default
            $table->string('status')->default('pending'); 
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reservations');
    }
};