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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            // Saya ubah menjadi constrained cascade agar jika reservasi dihapus, payment juga terhapus (lebih bersih)
            $table->foreignId('reservation_id')->constrained('reservations')->onDelete('cascade');
            $table->decimal('amount', 10, 2); // Menggunakan decimal untuk uang
            $table->string('payment_method')->default('bank_transfer');
            $table->string('payment_status')->default('pending'); // pending, verified, rejected
            $table->string('proof_of_payment'); // Kolom wajib untuk file upload
            $table->dateTime('payment_date')->useCurrent();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};