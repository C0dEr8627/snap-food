<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Foundation\\Auth\\User as Authenticatable;
use Illuminate\\Notifications\\Notifiable;
use Laravel\\Sanctum\\HasApiTokens;

class AdminUser extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'admin_users';

    protected $fillable = ['google_subject', 'name', 'email', 'password', 'is_active'];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function hasRole(string $role): bool
    {
        return $role === 'ADMIN';
    }

    public function hasAnyRole(array $roles): bool
    {
        return in_array('ADMIN', $roles, true);
    }
}
