<?php

namespace App\Services\Orders;

use App\Models\Order;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderStatusService
{
    public function transition(Order $order, string $targetStatus, User $actor): Order
    {
        return DB::transaction(function () use ($order, $targetStatus, $actor): Order {
            $locked = Order::query()->lockForUpdate()->findOrFail($order->id);

            if ($locked->status === $targetStatus || ! $locked->canTransitionTo($targetStatus)) {
                $exception = ValidationException::withMessages([
                    'status' => ['The order cannot transition from its current state to the requested state.'],
                ]);

                $exception->status = 409;
                throw $exception;
            }

            $fromStatus = $locked->status;
            $locked->status = $targetStatus;
            $locked->save();

            $locked->statusHistory()->create([
                'from_status' => $fromStatus,
                'to_status' => $targetStatus,
                'actor_id' => $actor->id,
            ]);

            return $locked->load('items', 'statusHistory');
        });
    }
}
