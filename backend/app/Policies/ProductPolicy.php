<?php

namespace App\Policies;

use App\Models\Product;
use Illuminate\Contracts\Auth\Authenticatable;

class ProductPolicy
{
    public function before(Authenticatable $user): ?bool
    {
        if (! $user->is_active) {
            return false;
        }

        return $user->hasRole('ADMIN') ? true : null;
    }

    public function viewAny(Authenticatable $user): bool
    {
        return $user->is_active;
    }

    public function view(Authenticatable $user, Product $product): bool
    {
        return $user->is_active;
    }

    public function create(Authenticatable $user): bool
    {
        return $user->is_active && $user->hasRole('ADMIN');
    }

    public function update(Authenticatable $user, Product $product): bool
    {
        return $user->is_active && $user->hasRole('ADMIN');
    }

    public function delete(Authenticatable $user, Product $product): bool
    {
        return $user->is_active && $user->hasRole('ADMIN');
    }
}
