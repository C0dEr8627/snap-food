<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DeliveryPartner extends \Illuminate\Database\Eloquent\Model
{
    protected $fillable = [
        'user_id',
        'is_approved',
        'is_active',
        'is_available',
        'approved_at',
        'approved_by',
    ];

    protected function casts(): array
    {
        return [
            'is_approved' => 'boolean',
            'is_active' => 'boolean',
            'is_available' => 'boolean',
            'approved_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function approver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
