<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\Orders\OrderStatusService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Gate;

class OrderController extends Controller
{
    public function index(Request $request): View
    {
        $validated = $request->validate([
            'q' => ['nullable', 'string', 'max:120'],
            'status' => ['nullable', 'string', 'in:PLACED,ACCEPTED,PREPARING,READY_FOR_PICKUP,ASSIGNED,PICKED_UP,OUT_FOR_DELIVERY,DELIVERED,CANCELLED'],
        ]);

        $query = Order::query()
            ->with(['customer', 'assignment.deliveryPartner.user'])
            ->latest('id');

        if (! empty($validated['q'])) {
            $term = $validated['q'];

            $query->where(function ($orders) use ($term): void {
                $orders
                    ->where('id', ctype_digit($term) ? (int) $term : -1)
                    ->orWhereHas('customer', function ($customer) use ($term): void {
                        $customer
                            ->where('name', 'like', "%{$term}%")
                            ->orWhere('email', 'like', "%{$term}%");
                    });
            });
        }

        if (! empty($validated['status'])) {
            $query->where('status', $validated['status']);
        }

        return view('admin.orders.index', [
            'orders' => $query->paginate(20)->withQueryString(),
            'statuses' => array_keys(Order::allowedTransitions()),
            'filters' => $validated,
        ]);
    }

    public function show(Order $order): View
    {
        Gate::authorize('view', $order);

        $order->load([
            'customer',
            'items.product',
            'assignment.deliveryPartner.user',
            'assignment.assigner',
            'statusHistory.actor',
            'invoice',
        ]);

        return view('admin.orders.show', [
            'order' => $order,
            'nextStatuses' => Order::allowedTransitions()[$order->status] ?? [],
        ]);
    }

    public function updateStatus(
        Request $request,
        Order $order,
        OrderStatusService $statusService
    ): RedirectResponse {
        Gate::authorize('updateStatus', $order);

        $validated = $request->validate([
            'status' => ['required', 'string', 'in:ACCEPTED,PREPARING,READY_FOR_PICKUP,ASSIGNED,PICKED_UP,OUT_FOR_DELIVERY,DELIVERED,CANCELLED'],
        ]);

        $statusService->transition($order, $validated['status'], $request->user());

        return redirect()
            ->route('admin.orders.show', $order)
            ->with('status', 'Order status updated.');
    }
}
