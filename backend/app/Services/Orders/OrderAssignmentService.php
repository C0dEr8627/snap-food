<?php

namespace App\Services\Orders;

use App\Exceptions\ConflictException;
use App\Models\DeliveryPartnerUser;
use App\Models\Order;
use App\Models\OrderAssignment;
use App\Models\OrderStatusHistory;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Facades\DB;

class OrderAssignmentService
{
    public function assign(Order $order, DeliveryPartnerUser $deliveryPartner, Authenticatable $actor): OrderAssignment
    {
        return DB::transaction(function () use ($order, $deliveryPartner, $actor): OrderAssignment {
            $lockedOrder = Order::query()->lockForUpdate()->findOrFail($order->id);

            if ($lockedOrder->status !== Order::STATUS_READY_FOR_PICKUP) {
                throw new ConflictException('Only orders ready for pickup can be assigned.');
            }

            $lockedPartner = DeliveryPartnerUser::query()->lockForUpdate()->findOrFail($deliveryPartner->id);

            if (! $lockedPartner->is_approved || ! $lockedPartner->is_active || ! $lockedPartner->is_available) {
                throw new ConflictException('Delivery partner is not eligible for assignment.');
            }

            if (OrderAssignment::query()->where('order_id', $lockedOrder->id)->exists()) {
                throw new ConflictException('Order is already assigned.');
            }

            $lockedPartner->is_available = false;
            $lockedPartner->save();

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
                'actor_type' => $actor::class,
            ]);

            return $assignment->load(
                'deliveryPartner:id,name,email,is_active,is_approved,is_available',
                'assigner:id,name,email',
                'order:id,customer_id,status,total'
            );
        });
    }
}
