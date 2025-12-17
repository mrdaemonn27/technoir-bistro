<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'reservation_id',
        'amount',
        'payment_method',
        'payment_status',
        'proof_of_payment',
        'payment_date',
        'xendit_invoice_id',
        'external_id',
        'invoice_url',
        'xendit_status',
        'paid_at',
    ];

    // Relasi ke Reservation
    public function reservation()
    {
        return $this->belongsTo(Reservation::class);
    }
}