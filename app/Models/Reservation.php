<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Reservation extends Model
{
    use HasFactory;

    // Izinkan kolom ini diisi
    protected $fillable = [
        'user_id',
        'table_id',
        'reservation_date',
        'guest_count',
        'status',
        'notes'
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
    // Relasi Many-to-Many ke Menu dengan tabel pivot 'menu_reservation'
    public function menus()
    {
        return $this->belongsToMany(Menu::class, 'menu_reservation')
                    ->withPivot('quantity')
                    ->withTimestamps();
    }

    // --- TAMBAHAN: Relasi ke Payment ---
    // Diperlukan agar Controller tidak error saat memanggil ->with('payment')
    public function payment()
    {
        return $this->hasOne(Payment::class);
    }
}