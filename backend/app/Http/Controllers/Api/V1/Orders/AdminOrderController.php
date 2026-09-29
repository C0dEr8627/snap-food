<?php

namespace App\Http\Controllers\Api\V1\Orders;

use App\Http\Requests\UpdateOrderStatusRequest;
use App\Models\Order;
use App\Services\Orders\OrderStatusService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;

class AdminOrderController
{
    public function updateStatus(
        UpdateOrderStatusRequest $request,
        Order $order,
        OrderStatusService $statusService
    ): JsonResponse {
        Gate::authorize('updateStatus', $order);

        $updated = $statusService->transition(
            $order,
            $request->validated('status'),
            $request->user()
        );

        return response()->json(['data' => $updated]);
    }
}
