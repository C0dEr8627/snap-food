<?php

namespace App\Services\Orders;

use App\Exceptions\OrderStateConflictException;
use App\Models\Order;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Facades\DB;

class OrderStatusService
{
    public function transition(Order $order, string $targetStatus, Authenticatable $actor, ?string $cancellationReason = null): Order
    {
        return DB::transaction(function () use ($order, $targetStatus, $actor): Order {
            $locked = Order::query()->lockForUpdate()->findOrFail($order->id);

            if ($locked->status === $targetStatus || ! $locked->canTransitionTo($targetStatus)) {
                throw new OrderStateConflictException;
            }

            $fromStatus = $locked->status;
            $locked->status = $targetStatus;
            $locked->cancellation_reason = $targetStatus === Order::STATUS_CANCELLED
                ? trim((string) $cancellationReason)
                : null;
            $locked->save();

            $locked->statusHistory()->create([
                'from_status' => $fromStatus,
                'to_status' => $targetStatus,
                'actor_id' => $actor->id,
                'actor_type' => $actor::class,
            ]);

            return $locked->load('items', 'statusHistory');
        });
    }
}
