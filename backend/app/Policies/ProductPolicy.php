<?php

namespace App\Policies;

use App\Models\Product;
use App\Models\User;

class ProductPolicy
{
    public function before(User $user): ?bool
    {
        return $user->is_active && $user->hasRole(User::ROLE_ADMIN) ? true : false;
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
        return $user->is_active;
    }

    public function update(User $user, Product $product): bool
    {
        return $user->is_active;
    }

    public function delete(User $user, Product $product): bool
    {
        return $user->is_active;
    }
}
