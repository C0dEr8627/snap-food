<?php

namespace App\Http\Controllers\Api\V1\Delivery;

use App\Exceptions\ConflictException;
use App\Models\DeliveryLocation;
use App\Models\DeliveryPartnerUser;
use App\Models\Order;
use App\Models\OrderAssignment;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class DeliveryLocationController
{
    private const STALE_AFTER_SECONDS = 120;

    public function store(Request $request, OrderAssignment $assignment): JsonResponse
    {
        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'accuracy' => ['nullable', 'numeric', 'min:0', 'max:10000'],
            'recorded_at' => ['required', 'date'],
        ]);

        $partner = $request->user();

        if (! $partner instanceof DeliveryPartnerUser || ! $partner->is_active || ! $partner->is_approved) {
            throw new AccessDeniedHttpException('Delivery partner access is not active.');
        }

        $location = DB::transaction(function () use ($assignment, $partner, $validated): DeliveryLocation {
            $lockedAssignment = OrderAssignment::query()
                ->lockForUpdate()
                ->findOrFail($assignment->id);

            if ((int) $lockedAssignment->delivery_partner_id !== (int) $partner->id) {
                throw new AccessDeniedHttpException('This assignment does not belong to the authenticated delivery partner.');
            }

            $order = Order::query()->lockForUpdate()->findOrFail($lockedAssignment->order_id);

            if (! in_array($order->status, [
                Order::STATUS_PICKED_UP,
                Order::STATUS_OUT_FOR_DELIVERY,
            ], true)) {
                throw new ConflictException('Location updates are only allowed for active delivery trips.');
            }

            $recordedAt = CarbonImmutable::parse($validated['recorded_at']);

            if ($recordedAt->greaterThan(now()->addMinutes(2))) {
                throw new ConflictException('Location timestamp cannot be materially in the future.');
            }

            return DeliveryLocation::create([
                'assignment_id' => $lockedAssignment->id,
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'accuracy' => $validated['accuracy'] ?? null,
                'recorded_at' => $recordedAt,
            ]);
        });

        return response()->json(['data' => $location], 201);
    }

    public function show(Request $request, Order $order): JsonResponse
    {
        $user = $request->user();

        if (
            ! $user->hasRole('ADMIN')
            && (! $user->hasRole('CUSTOMER') || (int) $order->customer_id !== (int) $user->id)
        ) {
            throw new AccessDeniedHttpException('You are not authorized to track this order.');
        }

        // Tracking starts as soon as an order is placed. Before assignment or
        // before the partner shares GPS, return status with an empty location
        // instead of a 409 that breaks the customer's tracking timeline.
        $assignment = $order->assignment()->with('deliveryPartner')->first();

        $location = $assignment
            ? DeliveryLocation::query()
                ->where('assignment_id', $assignment->id)
                ->latest('recorded_at')
                ->first()
            : null;

        $stale = $assignment !== null && (
            ! $location
            || $location->recorded_at->lt(now()->subSeconds(self::STALE_AFTER_SECONDS))
        );

        $partner = $assignment?->deliveryPartner;

        return response()->json([
            'data' => [
                'order_id' => $order->id,
                'status' => $order->status,
                'location' => $location,
                'is_stale' => $stale,
                'delivery_partner' => $partner ? [
                    'name' => $partner->name,
                    'phone' => $partner->phone,
                    'assigned_at' => $assignment->assigned_at,
                ] : null,
                'stale_after_seconds' => self::STALE_AFTER_SECONDS,
            ],
        ]);
    }
}
