<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Reservation extends Model
{
    // Relasi: 1 Reservasi milik 1 User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi: 1 Reservasi punya 1 Payment
    public function payment()
    {
        return $this->hasOne(Payment::class);
    }

    // Relasi: 1 Reservasi punya banyak Orders
    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
