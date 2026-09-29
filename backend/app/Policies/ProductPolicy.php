<?php

namespace App\Policies;

use App\Models\Product;
use App\Models\User;

class ProductPolicy
{
    public function before(User $user): ?bool
    {
        if (! $user->is_active) {
            return false;
        }

        return $user->hasRole(User::ROLE_ADMIN) ? true : null;
    }

    public function viewAny(User $user): bool
    {
        return $user->is_active;
    }

    public function view(User $user, Product $product): bool
    {
        return $user->is_active;
    }

    public function create(User $user): bool
    {
        return $user->is_active && $user->hasRole(User::ROLE_ADMIN);
    }

    public function update(User $user, Product $product): bool
    {
        return $user->is_active && $user->hasRole(User::ROLE_ADMIN);
    }

    public function delete(User $user, Product $product): bool
    {
        return $user->is_active && $user->hasRole(User::ROLE_ADMIN);
    }
}
