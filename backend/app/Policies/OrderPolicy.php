<?php

namespace App\Policies;

use App\Models\Order;
use App\Models\User;

class OrderPolicy
{
    public function before(User $user): ?bool
    {
        if (! $user->is_active) {
            return false;
        }

        return null;
    }

    public function viewAny(User $user): bool
    {
        return $user->hasRole(User::ROLE_CUSTOMER);
    }

    public function view(User $user, Order $order): bool
    {
        return $user->hasRole(User::ROLE_CUSTOMER)
            && $order->customer_id === $user->id;
    }

    public function create(User $user): bool
    {
        return $user->hasRole(User::ROLE_CUSTOMER);
    }

    public function updateStatus(User $user, Order $order): bool
    {
        return $user->hasRole(User::ROLE_ADMIN);
    }

    public function viewAdmin(User $user, Order $order): bool
    {
        return $user->hasRole(User::ROLE_ADMIN);
    }
}
