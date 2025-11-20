<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Menu extends Model
{
    use HasFactory;

    /**
     * Properti yang bisa diisi secara massal.
     */
    protected $fillable = [
        'name',
        'description',
        'price',
        'image',       // <--- TAMBAHKAN INI AGAR GAMBAR BISA DISIMPAN
        'category_id',
        'availability'
    ];

    /**
     * Satu Menu DIMILIKI OLEH (belongsTo) satu Kategori.
     */
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Satu Menu bisa ada di BANYAK (hasMany) Order.
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}