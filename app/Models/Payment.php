<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    // Relasi: 1 Payment milik 1 Reservasi
    public function reservation()
    {
        return $this->belongsTo(Reservation::class);
    }
}
