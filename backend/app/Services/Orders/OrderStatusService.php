<?php

namespace App\Services\Orders;

use App\Exceptions\OrderStateConflictException;
use App\Models\Order;
use App\Models\OrderAssignment;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Facades\DB;

class OrderStatusService
{
    public function transition(Order $order, string $targetStatus, Authenticatable $actor, ?string $cancellationReason = null): Order
    {
        return DB::transaction(function () use ($order, $targetStatus, $actor, $cancellationReason): Order {
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

            if (in_array($targetStatus, [Order::STATUS_DELIVERED, Order::STATUS_CANCELLED], true)) {
                $assignment = OrderAssignment::query()
                    ->where('order_id', $locked->id)
                    ->lockForUpdate()
                    ->first();

                if ($assignment !== null) {
                    $assignment->deliveryPartner()->lockForUpdate()->first()?->update([
                        'is_available' => true,
                    ]);
                }
            }

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
