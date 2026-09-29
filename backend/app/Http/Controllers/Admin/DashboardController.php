<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
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

        return view('admin.dashboard', compact('counts'));
    }
}
