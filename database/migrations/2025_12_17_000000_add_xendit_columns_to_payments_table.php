<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tambahan kolom untuk menyimpan data invoice Xendit.
     */
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->string('xendit_invoice_id')->nullable()->after('payment_status');
            $table->string('external_id')->nullable()->after('xendit_invoice_id');
            $table->string('invoice_url')->nullable()->after('external_id');
            $table->string('xendit_status')->nullable()->default('PENDING')->after('invoice_url');
            $table->timestamp('paid_at')->nullable()->after('xendit_status');
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropColumn([
                'xendit_invoice_id',
                'external_id',
                'invoice_url',
                'xendit_status',
                'paid_at',
            ]);
        });
    }
};

