<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\DeliveryPartner;
use App\Services\Orders\OrderAssignmentService;
use App\Exceptions\ConflictException;
use App\Services\Orders\OrderStatusService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Gate;
use App\Exceptions\OrderStateConflictException;

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
        Gate::authorize('viewAdmin', $order);

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
            'eligiblePartners' => $order->status === Order::STATUS_READY_FOR_PICKUP && ! $order->assignment
                ? DeliveryPartner::query()->with('user:id,name,email')->where('is_approved', true)->where('is_active', true)->where('is_available', true)->whereHas('user', fn ($users) => $users->where('is_active', true))->orderBy('id')->get()
                : collect(),
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

        try {
            $statusService->transition($order, $validated['status'], $request->user());
        } catch (OrderStateConflictException $e) {
            abort(409, $e->getMessage());
        }

        return redirect()
            ->route('admin.orders.show', $order)
            ->with('status', 'Order status updated.');
    }
}
