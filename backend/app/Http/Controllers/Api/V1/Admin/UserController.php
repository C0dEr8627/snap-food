<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Models\AdminUser;
use App\Models\CustomerUser;
use App\Models\DeliveryPartnerUser;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;

class UserController
{
    public function index(Request $request): JsonResponse
    {
        $role = strtoupper(trim((string) $request->query('role', 'ALL')));
        if (!in_array($role, ['ALL', 'ADMIN', 'CUSTOMER', 'DELIVERY_PARTNER'], true)) {
            return response()->json(['message' => 'Unsupported user role filter.'], 422);
        }

        $term = trim((string) $request->query('search', ''));
        $perPage = min(max((int) $request->integer('per_page', 20), 1), 100);
        $page = max((int) $request->integer('page', 1), 1);

        $users = collect();

        if (in_array($role, ['ALL', 'ADMIN'], true)) {
            $admins = AdminUser::query()
                ->when($term !== '', fn (Builder $query) => $this->applySearch($query, $term))
                ->get(['id', 'name', 'email', 'is_active', 'created_at'])
                ->map(fn (AdminUser $user) => $this->normalise($user, 'ADMIN'));
            $users = $users->concat($admins);
        }

        if (in_array($role, ['ALL', 'CUSTOMER'], true)) {
            $customers = CustomerUser::query()
                ->with(['addresses:id,user_id,label,recipient_name,address_line1,address_line2,city,state,postal_code,country'])
                ->withCount('orders')
                ->when($term !== '', fn (Builder $query) => $this->applySearch($query, $term))
                ->get()
                ->map(fn (CustomerUser $user) => $this->normalise($user, 'CUSTOMER'));
            $users = $users->concat($customers);
        }

        if (in_array($role, ['ALL', 'DELIVERY_PARTNER'], true)) {
            $partners = DeliveryPartnerUser::query()
                ->when($term !== '', fn (Builder $query) => $this->applySearch($query, $term))
                ->get(['id', 'name', 'email', 'is_active', 'created_at'])
                ->map(fn (DeliveryPartnerUser $user) => $this->normalise($user, 'DELIVERY_PARTNER'));
            $users = $users->concat($partners);
        }

        $users = $users->sortByDesc(fn (array $user) => $user['created_at'] ?? '')->values();
        $total = $users->count();
        $items = $users->slice(($page - 1) * $perPage, $perPage)->values();

        $paginator = new LengthAwarePaginator(
            $items,
            $total,
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()],
        );

        return response()->json(['data' => $paginator]);
    }

    private function applySearch(Builder $query, string $term): void
    {
        $query->where(function (Builder $where) use ($term): void {
            $where->where('id', 'like', '%'.$term.'%')
                ->orWhere('name', 'like', '%'.$term.'%')
                ->orWhere('email', 'like', '%'.$term.'%');
        });
    }

    private function normalise(object $user, string $role): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name ?? '',
            'email' => $user->email ?? '',
            'role' => $role,
            'is_active' => (bool) $user->is_active,
            'created_at' => $user->created_at?->toISOString() ?? '',
            'orders_count' => (int) ($user->orders_count ?? 0),
            'addresses' => $role === 'CUSTOMER'
                ? $user->addresses->map(fn ($address) => $address->toArray())->values()
                : [],
        ];
    }
}
