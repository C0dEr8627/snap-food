<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Models\AdminUser;
use App\Models\CustomerUser;
use App\Models\DeliveryPartnerUser;
use App\Models\Order;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController
{
    public function index(Request $request): JsonResponse
    {
        $now = Carbon::now();
        $today = $now->copy()->startOfDay();
        $weekStart = $now->copy()->startOfWeek();
        $previousWeekStart = $weekStart->copy()->subWeek();

        $todayOrders = Order::query()->where('created_at', '>=', $today);
        $weekOrders = Order::query()->where('created_at', '>=', $weekStart);
        $previousWeekOrders = Order::query()
            ->where('created_at', '>=', $previousWeekStart)
            ->where('created_at', '<', $weekStart);

        $activeStatuses = [
            Order::STATUS_PLACED,
            Order::STATUS_ACCEPTED,
            Order::STATUS_PREPARING,
            Order::STATUS_READY_FOR_PICKUP,
            Order::STATUS_ASSIGNED,
            Order::STATUS_PICKED_UP,
            Order::STATUS_OUT_FOR_DELIVERY,
        ];

        $todayRevenue = (float) (clone $todayOrders)
            ->where('status', Order::STATUS_DELIVERED)
            ->sum('total');
        $weekRevenue = (float) (clone $weekOrders)
            ->where('status', Order::STATUS_DELIVERED)
            ->sum('total');
        $previousWeekRevenue = (float) (clone $previousWeekOrders)
            ->where('status', Order::STATUS_DELIVERED)
            ->sum('total');

        $statusCounts = Order::query()
            ->whereIn('status', $activeStatuses)
            ->selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        $deliveredToday = (int) (clone $todayOrders)->where('status', Order::STATUS_DELIVERED)->count();
        $todayOrderCount = (int) (clone $todayOrders)->count();
        $weekOrderCount = (int) (clone $weekOrders)->count();

        $onlinePartners = DeliveryPartnerUser::query()
            ->where('is_active', true)
            ->where('is_approved', true)
            ->where('is_available', true)
            ->count();
        $approvedPartners = DeliveryPartnerUser::query()
            ->where('is_active', true)
            ->where('is_approved', true)
            ->count();
        $pendingPartnerApprovals = DeliveryPartnerUser::query()
            ->where('is_approved', false)
            ->count();

        $recentOrders = Order::query()
            ->with(['customer:id,name,email', 'assignment.deliveryPartner:id,name'])
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->limit(8)
            ->get([
                'id',
                'customer_id',
                'total',
                'status',
                'payment_method',
                'created_at',
            ]);

        $dailySales = collect(range(6, 0))->map(function (int $daysAgo) use ($now): array {
            $date = $now->copy()->subDays($daysAgo)->startOfDay();
            $next = $date->copy()->addDay();
            $revenue = (float) Order::query()
                ->where('created_at', '>=', $date)
                ->where('created_at', '<', $next)
                ->where('status', Order::STATUS_DELIVERED)
                ->sum('total');

            return [
                'date' => $date->toDateString(),
                'label' => $date->format('D'),
                'revenue' => round($revenue, 2),
                'orders' => (int) Order::query()
                    ->where('created_at', '>=', $date)
                    ->where('created_at', '<', $next)
                    ->count(),
            ];
        });

        $attention = [];
        if (($statusCounts[Order::STATUS_PLACED] ?? 0) > 0) {
            $attention[] = [
                'type' => 'orders',
                'severity' => 'high',
                'count' => (int) $statusCounts[Order::STATUS_PLACED],
                'title' => 'New orders awaiting acceptance',
                'detail' => 'Review and accept incoming orders.',
            ];
        }
        if ($pendingPartnerApprovals > 0) {
            $attention[] = [
                'type' => 'partners',
                'severity' => 'medium',
                'count' => $pendingPartnerApprovals,
                'title' => 'Delivery partners awaiting approval',
                'detail' => 'Review partner onboarding requests.',
            ];
        }
        if ($onlinePartners === 0 && $approvedPartners > 0 && ($statusCounts[Order::STATUS_OUT_FOR_DELIVERY] ?? 0) > 0) {
            $attention[] = [
                'type' => 'fleet',
                'severity' => 'high',
                'count' => (int) ($statusCounts[Order::STATUS_OUT_FOR_DELIVERY] ?? 0),
                'title' => 'No available delivery partners',
                'detail' => 'Active deliveries may need operational attention.',
            ];
        }
        if (count($attention) === 0) {
            $attention[] = [
                'type' => 'system',
                'severity' => 'good',
                'count' => 0,
                'title' => 'Operations are running normally',
                'detail' => 'No priority issues detected right now.',
            ];
        }

        return response()->json([
            'data' => [
                'generated_at' => $now->toISOString(),
                'kpis' => [
                    'today_revenue' => round($todayRevenue, 2),
                    'today_orders' => $todayOrderCount,
                    'active_orders' => array_sum(array_map('intval', $statusCounts->all())),
                    'delivered_today' => $deliveredToday,
                    'week_revenue' => round($weekRevenue, 2),
                    'week_orders' => $weekOrderCount,
                    'previous_week_revenue' => round($previousWeekRevenue, 2),
                    'online_partners' => $onlinePartners,
                    'approved_partners' => $approvedPartners,
                    'pending_partner_approvals' => $pendingPartnerApprovals,
                    'customers' => CustomerUser::count(),
                    'admins' => AdminUser::count(),
                ],
                'status_counts' => $statusCounts,
                'daily_sales' => $dailySales,
                'attention' => $attention,
                'recent_orders' => $recentOrders,
            ],
        ]);
    }
}
