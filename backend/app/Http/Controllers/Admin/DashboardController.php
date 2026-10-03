<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\DeliveryPartner;
use App\Models\Invoice;
use App\Models\Order;
use App\Models\OrderAssignment;
use App\Models\Product;
use App\Models\CustomerUser;
use Illuminate\Contracts\View\View;

class DashboardController extends Controller
{
    public function __invoke(): View
    {
        $counts = [
            'new' => Order::query()
                ->where('status', Order::STATUS_PLACED)
                ->count(),
            'active' => Order::query()
                ->where('status', Order::STATUS_ACCEPTED)
                ->count(),
            'preparing' => Order::query()
                ->where('status', Order::STATUS_PREPARING)
                ->count(),
            'awaiting_delivery' => Order::query()
                ->whereIn('status', [
                    Order::STATUS_READY_FOR_PICKUP,
                    Order::STATUS_ASSIGNED,
                ])
                ->count(),
            'active_delivery' => Order::query()
                ->whereIn('status', [
                    Order::STATUS_PICKED_UP,
                    Order::STATUS_OUT_FOR_DELIVERY,
                ])
                ->count(),
        ];

        $directoryCounts = [
            'categories' => Category::query()->count(),
            'products' => Product::query()->count(),
            'customers' => CustomerUser::query()->count(),
            'delivery_partners' => DeliveryPartner::query()->count(),
            'assignments' => OrderAssignment::query()->count(),
            'invoices' => Invoice::query()->count(),
        ];

        return view('admin.dashboard', compact('counts', 'directoryCounts'));
    }
}
