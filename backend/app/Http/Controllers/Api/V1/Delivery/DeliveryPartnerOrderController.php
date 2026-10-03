<?php

namespace App\Http\Controllers\Api\V1\Delivery;

use App\Exceptions\ConflictException;
use App\Models\DeliveryPartnerUser;
use App\Models\Order;
use App\Models\OrderAssignment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class DeliveryPartnerOrderController
{
    public function index(Request $request): JsonResponse
    {
        $partner = $request->user();

        if (! $partner instanceof DeliveryPartnerUser || ! $partner->is_active || ! $partner->is_approved) {
            throw new AccessDeniedHttpException('Delivery partner access is not active.');
        }

        return response()->json([
            'data' => OrderAssignment::query()
                ->where('delivery_partner_id', $partner->id)
                ->whereHas('order', fn ($query) => $query->whereIn('status', [
                    Order::STATUS_ASSIGNED,
                    Order::STATUS_PICKED_UP,
                    Order::STATUS_OUT_FOR_DELIVERY,
                ]))
                ->with(['order.customer:id,name,email', 'order.items'])
                ->orderByDesc('assigned_at')
                ->paginate(20),
        ]);
    }

    public function updateStatus(Request $request, OrderAssignment $assignment): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'string', 'in:'.implode(',', [
                Order::STATUS_PICKED_UP,
                Order::STATUS_OUT_FOR_DELIVERY,
                Order::STATUS_DELIVERED,
            ])],
        ]);

        $actor = $request->user();
        $partner = $actor;

        if (! $partner instanceof DeliveryPartnerUser || ! $partner->is_active || ! $partner->is_approved) {
            abort(403, 'Delivery partner access is not active.');
        }

        $order = DB::transaction(function () use ($assignment, $partner, $validated, $actor): Order {
            $lockedAssignment = OrderAssignment::query()->lockForUpdate()->findOrFail($assignment->id);

            if ((int) $lockedAssignment->delivery_partner_id !== (int) $partner->id) {
                throw new AccessDeniedHttpException('This assignment does not belong to the authenticated delivery partner.');
            }

            $order = Order::query()->lockForUpdate()->findOrFail($lockedAssignment->order_id);
            $target = $validated['status'];

            if (! $order->canTransitionTo($target)) {
                throw new ConflictException('Order cannot transition to the requested delivery status.');
            }

            $from = $order->status;
            $order->status = $target;
            $order->save();

            if ($target === Order::STATUS_DELIVERED) {
                $lockedPartner = DeliveryPartnerUser::query()->lockForUpdate()->findOrFail($lockedAssignment->delivery_partner_id);
                $lockedPartner->update(['is_available' => true]);
            }

            $order->statusHistory()->create([
                'from_status' => $from,
                'to_status' => $target,
                'actor_id' => $actor->id,
                'actor_type' => $actor::class,
            ]);

            return $order->load('items');
        });

        return response()->json(['data' => $order]);
    }
}
