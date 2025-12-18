<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Ubah relasi favorites dari order ke menu.
     */
    public function up(): void
    {
        Schema::table('favorites', function (Blueprint $table) {
            if (Schema::hasColumn('favorites', 'order_id')) {
                $table->dropForeign(['order_id']);
                $table->dropColumn('order_id');
            }

            if (!Schema::hasColumn('favorites', 'menu_id')) {
                $table->foreignId('menu_id')->after('user_id')->constrained('menus')->onDelete('cascade');
            }
        });
    }

    public function down(): void
    {
        Schema::table('favorites', function (Blueprint $table) {
            if (Schema::hasColumn('favorites', 'menu_id')) {
                $table->dropForeign(['menu_id']);
                $table->dropColumn('menu_id');
            }

            if (!Schema::hasColumn('favorites', 'order_id')) {
                $table->foreignId('order_id')->constrained('orders')->onDelete('cascade');
            }
        });
    }
};


