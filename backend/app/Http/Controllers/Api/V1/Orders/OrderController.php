<?php

namespace App\Http\Controllers\Api\V1\Orders;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreOrderRequest;
use App\Models\Order;
use App\Services\Orders\OrderCheckoutService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;

class OrderController
{
    public function index(): JsonResponse
    {
        Gate::authorize('viewAny', Order::class);

        $orders = Order::query()
            ->with('items')
            ->where('customer_id', request()->user()->id)
            ->latest()
            ->paginate(min(max((int) request()->integer('per_page', 20), 1), 100));

        return response()->json(['data' => $orders]);
    }

    public function store(StoreOrderRequest $request, OrderCheckoutService $checkout): JsonResponse
    {
        Gate::authorize('create', Order::class);

        $order = $checkout->create($request);

        return response()->json(['data' => $order], 201);
    }

    public function show(Order $order): JsonResponse
    {
        Gate::authorize('view', $order);

        return response()->json([
            'data' => $order->load('items', 'statusHistory'),
        ]);
    }
}
