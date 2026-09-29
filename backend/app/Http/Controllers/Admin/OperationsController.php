<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DeliveryPartner;
use App\Models\Invoice;
use App\Models\OrderAssignment;
use App\Models\User;
use Illuminate\Contracts\View\View;
use Illuminate\Http\Request;

class OperationsController extends Controller
{
    public function customers(Request $request): View
    {
        $validated = $request->validate(['q' => ['nullable', 'string', 'max:120']]);
        $query = User::query()->where('role', User::ROLE_CUSTOMER)->latest('id');

        if (! empty($validated['q'])) {
            $term = $validated['q'];
            $query->where(fn ($users) => $users
                ->where('name', 'like', "%{$term}%")
                ->orWhere('email', 'like', "%{$term}%"));
        }

        return view('admin.customers.index', [
            'customers' => $query->paginate(20)->withQueryString(),
            'filters' => $validated,
        ]);
    }

    public function deliveryPartners(Request $request): View
    {
        $validated = $request->validate([
            'q' => ['nullable', 'string', 'max:120'],
            'state' => ['nullable', 'in:approved,pending,inactive,available'],
        ]);
        $query = DeliveryPartner::query()->with('user:id,name,email,is_active')->latest('id');

        if (! empty($validated['q'])) {
            $term = $validated['q'];
            $query->whereHas('user', fn ($users) => $users
                ->where('name', 'like', "%{$term}%")
                ->orWhere('email', 'like', "%{$term}%"));
        }

        if (($validated['state'] ?? null) === 'approved') {
            $query->where('is_approved', true)->where('is_active', true);
        } elseif (($validated['state'] ?? null) === 'pending') {
            $query->where('is_approved', false);
        } elseif (($validated['state'] ?? null) === 'inactive') {
            $query->where('is_active', false);
        } elseif (($validated['state'] ?? null) === 'available') {
            $query->where('is_approved', true)->where('is_active', true)->where('is_available', true);
        }

        return view('admin.delivery-partners.index', [
            'partners' => $query->paginate(20)->withQueryString(),
            'filters' => $validated,
        ]);
    }

    public function assignments(Request $request): View
    {
        $validated = $request->validate([
            'q' => ['nullable', 'string', 'max:120'],
            'status' => ['nullable', 'in:PLACED,ACCEPTED,PREPARING,READY_FOR_PICKUP,ASSIGNED,PICKED_UP,OUT_FOR_DELIVERY,DELIVERED,CANCELLED'],
        ]);
        $query = OrderAssignment::query()
            ->with(['order.customer', 'deliveryPartner.user', 'assigner'])
            ->whereHas('order')
            ->latest('id');

        if (! empty($validated['q'])) {
            $term = $validated['q'];
            $query->where(function ($assignments) use ($term): void {
                if (ctype_digit($term)) {
                    $assignments->where('order_id', (int) $term);
                }
                $assignments->orWhereHas('order.customer', fn ($users) => $users
                    ->where('name', 'like', "%{$term}%")
                    ->orWhere('email', 'like', "%{$term}%"))
                    ->orWhereHas('deliveryPartner.user', fn ($users) => $users
                        ->where('name', 'like', "%{$term}%")
                        ->orWhere('email', 'like', "%{$term}%"));
            });
        }

        if (! empty($validated['status'])) {
            $query->whereHas('order', fn ($orders) => $orders->where('status', $validated['status']));
        }

        return view('admin.assignments.index', [
            'assignments' => $query->paginate(20)->withQueryString(),
            'statuses' => array_keys(\App\Models\Order::allowedTransitions()),
            'filters' => $validated,
        ]);
    }

    public function invoices(Request $request): View
    {
        $validated = $request->validate(['q' => ['nullable', 'string', 'max:120']]);
        $query = Invoice::query()->with('order.customer')->latest('id');

        if (! empty($validated['q'])) {
            $term = $validated['q'];
            $query->where(function ($invoices) use ($term): void {
                $invoices->where('invoice_number', 'like', "%{$term}%")
                    ->orWhereHas('order', function ($orders) use ($term): void {
                        if (ctype_digit($term)) {
                            $orders->where('id', (int) $term);
                        }
                        $orders->orWhereHas('customer', fn ($users) => $users
                            ->where('name', 'like', "%{$term}%")
                            ->orWhere('email', 'like', "%{$term}%"));
                    });
            });
        }

        return view('admin.invoices.index', [
            'invoices' => $query->paginate(20)->withQueryString(),
            'filters' => $validated,
        ]);
    }
}
