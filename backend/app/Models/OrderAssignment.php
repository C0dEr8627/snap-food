<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrderAssignment extends Model
{
    protected $fillable = [
        'order_id',
        'delivery_partner_id',
        'assigned_by',
        'assigned_at',
    ];

    protected function casts(): array
    {
        return ['assigned_at' => 'datetime'];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function deliveryPartner(): BelongsTo
    {
        return $this->belongsTo(DeliveryPartnerUser::class, 'delivery_partner_id');
    }

    public function assigner(): BelongsTo
    {
        return $this->belongsTo(AdminUser::class, 'assigned_by');
    }
}
