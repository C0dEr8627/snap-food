<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
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

    protected $fillable = ['name', 'email', 'phone', 'password', 'is_active'];

    protected $hidden = ['password', 'remember_token'];

    protected $appends = ['role'];

    public function getRoleAttribute(): string
    {
        return 'DELIVERY_PARTNER';
    }

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function deliveryPartner()
    {
        return $this->hasOne(DeliveryPartner::class, 'user_id');
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
