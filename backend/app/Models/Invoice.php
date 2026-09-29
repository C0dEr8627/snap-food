<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Invoice extends Model
{
    protected $fillable = [
        'order_id',
        'invoice_number',
        'customer_name',
        'customer_email',
        'delivery_address_snapshot',
        'items_snapshot',
        'subtotal',
        'delivery_fee',
        'total',
        'payment_method',
        'payment_status',
        'issued_at',
        'file_reference',
    ];

    protected function casts(): array
    {
        return [
            'delivery_address_snapshot' => 'array',
            'items_snapshot' => 'array',
            'subtotal' => 'decimal:2',
            'delivery_fee' => 'decimal:2',
            'total' => 'decimal:2',
            'issued_at' => 'datetime',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
