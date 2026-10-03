<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CustomerUser;
use App\Models\DeliveryPartner;
use App\Models\Invoice;
use App\Models\Order;
use App\Models\OrderAssignment;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OperationsController extends Controller
{
    public function updatePartnerApproval(Request $request, DeliveryPartner $deliveryPartner): RedirectResponse
    {
        $validated = $request->validate(['approved' => ['required', 'boolean']]);
        $approved = (bool) $validated['approved'];

        DB::transaction(function () use ($approved, $deliveryPartner, $request): void {
            $partner = DeliveryPartner::query()->lockForUpdate()->findOrFail($deliveryPartner->id);
            $partner->is_approved = $approved;
            $partner->approved_at = $approved ? now() : null;
            $partner->approved_by = $approved ? $request->user()->id : null;
            if (! $approved) {
                $partner->is_available = false;
            }
            $partner->save();
        });

        return redirect()->route('admin.delivery-partners.index')->with('status', $approved ? 'Delivery partner approved.' : 'Delivery partner approval revoked.');
    }

    public function updatePartnerState(Request $request, DeliveryPartner $deliveryPartner): RedirectResponse
    {
        $validated = $request->validate(['action' => ['required', 'in:activate,deactivate,available,unavailable']]);

        DB::transaction(function () use ($validated, $deliveryPartner): void {
            $partner = DeliveryPartner::query()->with('user')->lockForUpdate()->findOrFail($deliveryPartner->id);
            $action = $validated['action'];

            if ($action === 'activate' && ! $partner->user->is_active) {
                abort(409, 'An inactive user account cannot be activated as a delivery partner.');
            }

            if ($action === 'available' && (! $partner->is_approved || ! $partner->is_active || ! $partner->user->is_active)) {
                abort(409, 'Only approved and active delivery partners can be made available.');
            }

            if ($action === 'activate') {
                $partner->is_active = true;
                $partner->is_available = false;
            } elseif ($action === 'deactivate') {
                $partner->is_active = false;
                $partner->is_available = false;
            } elseif ($action === 'available') {
                $partner->is_available = true;
            } else {
                $partner->is_available = false;
            }

            $partner->save();
        });

        return redirect()->route('admin.delivery-partners.index')->with('status', 'Delivery partner state updated.');
    }

    public function customers(Request $request): View
    {
        $validated = $request->validate(['q' => ['nullable', 'string', 'max:120']]);
        $query = CustomerUser::query()->latest('id');

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
            'statuses' => array_keys(Order::allowedTransitions()),
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
