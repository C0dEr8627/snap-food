<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    public const ROLE_CUSTOMER = 'CUSTOMER';

    public const ROLE_DELIVERY_PARTNER = 'DELIVERY_PARTNER';

    public const ROLE_ADMIN = 'ADMIN';

    use HasApiTokens, Notifiable;

    protected $fillable = [
        'google_subject',
        'name',
        'email',
        'role',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    public function hasRole(string $role): bool
    {
        return $this->role === $role;
    }

    public function hasAnyRole(array $roles): bool
    {
        return in_array($this->role, $roles, true);
    }

    public function addresses()
    {
        return $this->hasMany(Address::class);
    }

    public function deliveryPartner()
    {
        return $this->hasOne(DeliveryPartner::class);
    }
}
