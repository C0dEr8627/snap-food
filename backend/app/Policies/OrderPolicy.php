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

    public function viewAny(Authenticatable $user): bool
    {
        return $user->hasRole('CUSTOMER');
    }

    public function view(Authenticatable $user, Order $order): bool
    {
        return $user->hasRole('CUSTOMER')
            && (int) $order->customer_id === (int) $user->id;
    }

    public function create(Authenticatable $user): bool
    {
        return $user->hasRole('CUSTOMER');
    }

    public function updateStatus(Authenticatable $user, Order $order): bool
    {
        return $user->hasRole('ADMIN');
    }

    public function viewAdmin(Authenticatable $user, Order $order): bool
    {
        return $user->hasRole('ADMIN');
    }
}
