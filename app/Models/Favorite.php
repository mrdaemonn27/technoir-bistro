<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Favorite extends Model
{
    // Beri tahu model kolom apa saja yang boleh diisi
    protected $fillable = [
        'user_id',
        'menu_id',
    ];

    // Relasi: 1 Favorite milik 1 User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi: 1 Favorite merujuk ke 1 Menu yang disukai user
    public function menu()
    {
        return $this->belongsTo(Menu::class);
    }
}
