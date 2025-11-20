<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    // Relasi: 1 Order milik 1 Reservasi
    public function reservation()
    {
        return $this->belongsTo(Reservation::class);
    }

    // Relasi: 1 Order milik 1 Menu
    public function menu()
    {
        return $this->belongsTo(Menu::class);
    }
}
