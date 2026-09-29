<?php

namespace App\Policies;

use App\Models\Category;
use App\Models\User;

class CategoryPolicy
{
    public function before(User $user): ?bool
    {
        return $user->hasRole(User::ROLE_ADMIN) ? true : false;
    }

    public function viewAny(User $user): bool
    {
        return $user->is_active;
    }

    public function view(User $user, Category $category): bool
    {
        return $user->is_active;
    }

    public function create(User $user): bool
    {
        return $user->is_active;
    }

    public function update(User $user, Category $category): bool
    {
        return $user->is_active;
    }

    public function delete(User $user, Category $category): bool
    {
        return $user->is_active;
    }
}
