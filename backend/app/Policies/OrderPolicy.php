<?php

namespace App\Policies;

use App\Models\Order;
use Illuminate\Contracts\Auth\Authenticatable;

class OrderPolicy
{
    public function before(Authenticatable $user): ?bool
    {
        if (! $user->is_active) {
            return false;
        }

        return null;
    }

    public function viewAny(User $user): bool
    {
        return $user->hasRole('CUSTOMER');
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
        return $user->hasRole('ADMIN');
    }

    public function viewAdmin(User $user, Order $order): bool
    {
        return $user->hasRole(User::ROLE_ADMIN);
    }
}
