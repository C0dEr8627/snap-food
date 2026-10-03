<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Foundation\\Auth\\User as Authenticatable;
use Illuminate\\Notifications\\Notifiable;
use Laravel\\Sanctum\\HasApiTokens;

class DeliveryPartnerUser extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'delivery_partner_users';

    protected $fillable = ['name', 'email', 'phone', 'password', 'is_active'];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function hasRole(string $role): bool
    {
        return $role === 'DELIVERY_PARTNER';
    }

    public function hasAnyRole(array $roles): bool
    {
        return $this->hasRole(in_array('CUSTOMER', $roles, true) ? 'CUSTOMER' : (in_array('DELIVERY_PARTNER', $roles, true) ? 'DELIVERY_PARTNER' : 'ADMIN'));
    }
}
