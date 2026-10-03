<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class CustomerUser extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'customer_users';

    protected $fillable = ['google_subject', 'name', 'email', 'phone', 'password', 'is_active'];

    protected $hidden = ['password', 'remember_token'];

    protected $appends = ['role'];

    public function getRoleAttribute(): string
    {
        return 'CUSTOMER';
    }

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function orders()
    {
        return $this->hasMany(Order::class, 'customer_id');
    }

    public function addresses()
    {
        return $this->hasMany(Address::class, 'user_id');
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class, 'user_id');
    }

    public function cartItems()
    {
        return $this->hasMany(Cart::class, 'user_id');
    }

    public function hasRole(string $role): bool
    {
        return $role === 'CUSTOMER';
    }

    public function hasAnyRole(array $roles): bool
    {
        return in_array('CUSTOMER', $roles, true);
    }
}
