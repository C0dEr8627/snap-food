<?php

namespace App\Http\Controllers\Api\V1\Orders;

use App\Http\Requests\UpdateOrderStatusRequest;
use App\Models\Order;
use App\Services\Orders\OrderStatusService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;

class AdminOrderController
{
    public function index(\Illuminate\Http\Request $request): JsonResponse
    {
        $query = Order::query()
            ->with([
                'customer:id,name,email',
                'items:id,order_id,product_id,product_name,unit_price,quantity,line_total',
                'assignment.deliveryPartner.user:id,name,email',
            ])
            ->latest('id')
            ->when($request->filled('search'), function ($builder) use ($request): void {
                $term = trim((string) $request->query('search'));
                $builder->where(function ($where) use ($term): void {
                    $where->where('id', 'like', '%'.$term.'%')
                        ->orWhere('status', 'like', '%'.$term.'%')
                        ->orWhereHas('customer', fn ($customers) => $customers
                            ->where('name', 'like', '%'.$term.'%')
                            ->orWhere('email', 'like', '%'.$term.'%'));
                });
            })
            ->when($request->filled('status') && $request->query('status') !== 'ALL', fn ($builder) =>
                $builder->where('status', $request->query('status'))
            );

        $orders = $query->paginate(min(max((int) $request->integer('per_page', 20), 1), 100))
            ->withQueryString();

        return response()->json(['data' => $orders]);
    }

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
