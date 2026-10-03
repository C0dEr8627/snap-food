<?php

namespace App\Policies;

use App\Models\Address;
use Illuminate\Contracts\Auth\Authenticatable;

class AddressPolicy
{
    public function before(Authenticatable $user): ?bool
    {
        return $user->is_active && $user->hasRole('ADMIN') ? true : null;
    }

    public function view(Authenticatable $user, Address $address): bool
    {
        return $address->user_id === $user->id;
    }

    public function create(Authenticatable $user): bool
    {
        return $user->is_active && $user->hasRole('CUSTOMER');
    }

    public function update(Authenticatable $user, Address $address): bool
    {
        return $address->user_id === $user->id;
    }

    public function delete(Authenticatable $user, Address $address): bool
    {
        return $address->user_id === $user->id;
    }
}
