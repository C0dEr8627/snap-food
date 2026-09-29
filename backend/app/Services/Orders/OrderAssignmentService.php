<?php

namespace App\Services\Orders;

use App\Exceptions\ConflictException;
use App\Models\DeliveryPartner;
use App\Models\Order;
use App\Models\OrderAssignment;
use App\Models\OrderStatusHistory;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class OrderAssignmentService
{
    public function assign(Order $order, DeliveryPartner $deliveryPartner, User $actor): OrderAssignment
    {
        return DB::transaction(function () use ($order, $deliveryPartner, $actor): OrderAssignment {
            $lockedOrder = Order::query()->lockForUpdate()->findOrFail($order->id);

            if ($lockedOrder->status !== Order::STATUS_READY_FOR_PICKUP) {
                throw new ConflictException('Only orders ready for pickup can be assigned.');
            }

            $lockedPartner = DeliveryPartner::query()
                ->lockForUpdate()
                ->findOrFail($deliveryPartner->id);

            if (! $lockedPartner->is_approved || ! $lockedPartner->is_active || ! $lockedPartner->is_available) {
                throw new ConflictException('Delivery partner is not eligible for assignment.');
            }

            if (OrderAssignment::query()->where('order_id', $lockedOrder->id)->exists()) {
                throw new ConflictException('Order is already assigned.');
            }

            $assignment = OrderAssignment::create([
                'order_id' => $lockedOrder->id,
                'delivery_partner_id' => $lockedPartner->id,
                'assigned_by' => $actor->id,
                'assigned_at' => now(),
            ]);

            $fromStatus = $lockedOrder->status;
            $lockedOrder->status = Order::STATUS_ASSIGNED;
            $lockedOrder->save();

            OrderStatusHistory::create([
                'order_id' => $lockedOrder->id,
                'from_status' => $fromStatus,
                'to_status' => Order::STATUS_ASSIGNED,
                'actor_id' => $actor->id,
            ]);

            return $assignment->load(
                'deliveryPartner.user:id,name,email,role,is_active',
                'assigner:id,name,email',
                'order:id,customer_id,status,total'
            );
        });
    }
}
