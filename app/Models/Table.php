<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Table extends Model
{
    use HasFactory;

    protected $fillable = [
        'table_number', // Nomor Meja (misal: "A1", "B2")
        'capacity',     // Kapasitas (2 orang, 4 orang)
        'status',       // FR-07: available, occupied, reserved, cleaning
        'location'      // Indoor, Outdoor, Rooftop
    ];

    // Kita bisa tambahkan scope untuk mempermudah filter nanti (FR-05)
    public function scopeAvailable($query)
    {
        return $query->where('status', 'available');
    }
}