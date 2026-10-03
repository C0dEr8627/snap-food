<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Models\CustomerUser;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController
{
    public function index(Request $request): JsonResponse
    {
        $query = CustomerUser::query()
            ->with([
                'addresses:id,user_id,label,recipient_name,address_line1,address_line2,city,state,postal_code,country',
            ])
            ->withCount('orders')
            ->latest('id')
            ->when($request->filled('search'), function ($builder) use ($request): void {
                $term = trim((string) $request->query('search'));
                $builder->where(function ($where) use ($term): void {
                    $where->where('id', 'like', '%'.$term.'%')
                        ->orWhere('name', 'like', '%'.$term.'%')
                        ->orWhere('email', 'like', '%'.$term.'%');
                });
            });

        return response()->json([
            'data' => $query->paginate(min(max((int) $request->integer('per_page', 20), 1), 100))->withQueryString(),
        ]);
    }
}
