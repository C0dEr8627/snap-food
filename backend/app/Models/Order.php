<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    public const STATUS_PLACED = 'PLACED';
    public const STATUS_ACCEPTED = 'ACCEPTED';
    public const STATUS_PREPARING = 'PREPARING';
    public const STATUS_READY_FOR_PICKUP = 'READY_FOR_PICKUP';
    public const STATUS_ASSIGNED = 'ASSIGNED';
    public const STATUS_PICKED_UP = 'PICKED_UP';
    public const STATUS_OUT_FOR_DELIVERY = 'OUT_FOR_DELIVERY';
    public const STATUS_DELIVERED = 'DELIVERED';
    public const STATUS_CANCELLED = 'CANCELLED';

    public const PAYMENT_METHOD_COD = 'COD';
    public const PAYMENT_STATUS_PENDING = 'PENDING';

    protected $fillable = [
        'customer_id',
        'delivery_address_snapshot',
        'subtotal',
        'delivery_fee',
        'total',
        'payment_method',
        'payment_status',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'delivery_address_snapshot' => 'array',
            'subtotal' => 'decimal:2',
            'delivery_fee' => 'decimal:2',
            'total' => 'decimal:2',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function assignment(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(OrderAssignment::class);
    }

    public function statusHistory(): HasMany
    {
        return $this->hasMany(OrderStatusHistory::class);
    }

    public static function allowedTransitions(): array
    {
        return [
            self::STATUS_PLACED => [self::STATUS_ACCEPTED, self::STATUS_CANCELLED],
            self::STATUS_ACCEPTED => [self::STATUS_PREPARING, self::STATUS_CANCELLED],
            self::STATUS_PREPARING => [self::STATUS_READY_FOR_PICKUP, self::STATUS_CANCELLED],
            self::STATUS_READY_FOR_PICKUP => [self::STATUS_ASSIGNED, self::STATUS_CANCELLED],
            self::STATUS_ASSIGNED => [self::STATUS_PICKED_UP, self::STATUS_CANCELLED],
            self::STATUS_PICKED_UP => [self::STATUS_OUT_FOR_DELIVERY],
            self::STATUS_OUT_FOR_DELIVERY => [self::STATUS_DELIVERED],
            self::STATUS_DELIVERED => [],
            self::STATUS_CANCELLED => [],
        ];
    }

    public function canTransitionTo(string $status): bool
    {
        return in_array($status, self::allowedTransitions()[$this->status] ?? [], true);
    }
}
