<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'username',    // Pastikan ini username
        'email',
        'password',
        'is_verified', // Tambahan kolom baru
        'is_admin',    // Tambahan kolom baru
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            // Tambahan: Casting agar otomatis jadi boolean (true/false)
            'is_verified' => 'boolean',
            'is_admin' => 'boolean',
        ];
    }

    /* CATATAN: Relasi di bawah ini SAYA KOMENTAR DULU.
       Nyalakan kembali nanti setelah Anda membuat Model Reservation dan Favorite.
       Jika dinyalakan sekarang, akan error "Class not found".
    */

    /*
    // Relasi: 1 User punya banyak Reservations
    public function reservations()
    {
        return $this->hasMany(Reservation::class);
    }

    // Relasi: 1 User punya banyak Favorites
    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
    */
}