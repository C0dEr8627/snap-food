<?php

namespace App\Http\Controllers\Api\V1\Delivery;

use App\Exceptions\ConflictException;
use App\Models\Order;
use App\Models\OrderAssignment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DeliveryPartnerOrderController
{
    public function index(Request $request): JsonResponse
    {
        $partner = $request->user()->deliveryPartner;

        if (! $partner || ! $partner->is_active || ! $partner->is_approved) {
            abort(403, 'Delivery partner access is not active.');
        }

        return response()->json([
            'data' => OrderAssignment::query()
                ->where('delivery_partner_id', $partner->id)
                ->whereHas('order', fn ($query) => $query->whereIn('status', [
                    Order::STATUS_ASSIGNED,
                    Order::STATUS_PICKED_UP,
                    Order::STATUS_OUT_FOR_DELIVERY,
                ]))
                ->with([
                    'order.customer:id,name,email',
                    'order.items',
                ])
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

        $partner = $request->user()->deliveryPartner;

        if (! $partner || ! $partner->is_active || ! $partner->is_approved) {
            abort(403, 'Delivery partner access is not active.');
        }

        $order = DB::transaction(function () use ($assignment, $partner, $validated, $request): Order {
            $lockedAssignment = OrderAssignment::query()
                ->lockForUpdate()
                ->findOrFail($assignment->id);

            if ((int) $lockedAssignment->delivery_partner_id !== (int) $partner->id) {
                return response()->json([
                    'message' => 'This assignment does not belong to the authenticated delivery partner.',
                    'errors' => [],
                    'code' => 'FORBIDDEN',
                ], 403);
            }

            $order = Order::query()->lockForUpdate()->findOrFail($lockedAssignment->order_id);
            $target = $validated['status'];

            if (! $order->canTransitionTo($target)) {
                throw new ConflictException('Order cannot transition to the requested delivery status.');
            }

            $from = $order->status;
            $order->status = $target;
            $order->save();

            $order->statusHistory()->create([
                'from_status' => $from,
                'to_status' => $target,
                'actor_id' => $request->user()->id,
            ]);

            return $order->load('items');
        });

        return response()->json(['data' => $order]);
    }
}
