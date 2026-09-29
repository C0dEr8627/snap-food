<?php

namespace App\Policies;

use App\Models\Address;
use App\Models\User;

class AddressPolicy
{
    public function before(User $user): ?bool
    {
        return $user->is_active && $user->hasRole(User::ROLE_ADMIN) ? true : null;
    }

    public function view(User $user, Address $address): bool
    {
        return $address->user_id === $user->id;
    }

    public function create(User $user): bool
    {
        return $user->is_active && $user->hasRole(User::ROLE_CUSTOMER);
    }

    public function update(User $user, Address $address): bool
    {
        return $address->user_id === $user->id;
    }

    public function delete(User $user, Address $address): bool
    {
        return $address->user_id === $user->id;
    }
}
