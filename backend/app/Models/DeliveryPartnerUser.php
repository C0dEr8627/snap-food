<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class DeliveryPartnerUser extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'delivery_partner_users';

    protected static function newFactory()
    {
        return \Database\Factories\RiderUserFactory::new();
    }

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'is_active',
        'is_approved',
        'is_available',
        'approved_at',
        'approved_by',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $appends = ['role'];

    public function getRoleAttribute(): string
    {
        return 'DELIVERY_PARTNER';
    }

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'is_approved' => 'boolean',
            'is_available' => 'boolean',
            'approved_at' => 'datetime',
        ];
    }

    public function approver(): BelongsTo
    {
        return $this->belongsTo(AdminUser::class, 'approved_by');
    }

    public function hasRole(string $role): bool
    {
        return $role === 'DELIVERY_PARTNER';
    }

    public function hasAnyRole(array $roles): bool
    {
        return in_array('DELIVERY_PARTNER', $roles, true);
    }
}
