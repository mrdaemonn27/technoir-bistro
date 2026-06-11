<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Reservation extends Model
{
    use HasFactory;

    // Tambahkan 'total_price' di sini agar bisa diisi (Mass Assignment)
    protected $fillable = [
        'user_id',
        'table_id',
        'reservation_date',
        'guest_count',
        'status',
        'notes',
        'total_price', // <--- TAMBAHKAN INI
    ];

    // Casting untuk memastikan tanggal formatnya benar saat dipanggil
    protected $casts = [
        'reservation_date' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function table()
    {
        return $this->belongsTo(Table::class);
    }

    // RELASI UNTUK FITUR PESAN MAKAN (FR-06)
    public function menus()
    {
        return $this->belongsToMany(Menu::class, 'menu_reservation')
                    ->withPivot('quantity')
                    ->withTimestamps();
    }

    // --- TAMBAHAN: Relasi ke Payment ---
    public function payment()
    {
        return $this->hasOne(Payment::class);
    }
}