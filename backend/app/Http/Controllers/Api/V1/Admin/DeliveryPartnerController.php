<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Exceptions\ConflictException;
use App\Http\Controllers\Controller;
use App\Http\Requests\ProvisionDeliveryPartnerRequest;
use App\Http\Requests\UpdateDeliveryPartnerApprovalRequest;
use App\Models\DeliveryPartner;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class DeliveryPartnerController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => DeliveryPartner::query()
                ->with('user:id,name,email,role,is_active')
                ->orderByDesc('id')
                ->paginate(20),
        ]);
    }

    public function store(ProvisionDeliveryPartnerRequest $request): JsonResponse
    {
        $partner = DB::transaction(function () use ($request): DeliveryPartner {
            $user = User::query()->lockForUpdate()->findOrFail($request->integer('user_id'));

            if (! $user->is_active) {
                abort(Response::HTTP_UNPROCESSABLE_ENTITY, 'Inactive users cannot be provisioned as delivery partners.');
            }

            if ($user->hasRole(User::ROLE_ADMIN)) {
                throw new ConflictException('Admin users cannot be provisioned as delivery partners.');
            }

            if ($user->hasRole(User::ROLE_DELIVERY_PARTNER)) {
                throw new ConflictException('User is already a delivery partner.');
            }

            $user->update(['role' => User::ROLE_DELIVERY_PARTNER]);

            return DeliveryPartner::create([
                'user_id' => $user->id,
                'is_approved' => false,
                'is_active' => true,
                'is_available' => false,
            ])->load('user:id,name,email,role,is_active');
        });

        return response()->json(['data' => $partner], Response::HTTP_CREATED);
    }

    public function updateApproval(
        UpdateDeliveryPartnerApprovalRequest $request,
        DeliveryPartner $deliveryPartner
    ): JsonResponse {
        $approved = $request->boolean('approved');

        $partner = DB::transaction(function () use ($approved, $deliveryPartner, $request): DeliveryPartner {
            $partner = DeliveryPartner::query()->lockForUpdate()->findOrFail($deliveryPartner->id);

            $partner->is_approved = $approved;
            $partner->approved_at = $approved ? now() : null;
            $partner->approved_by = $approved ? $request->user()->id : null;

            if (! $approved) {
                $partner->is_available = false;
            }

            $partner->save();

            return $partner->load('user:id,name,email,role,is_active', 'approver:id,name,email');
        });

        return response()->json(['data' => $partner]);
    }
}
