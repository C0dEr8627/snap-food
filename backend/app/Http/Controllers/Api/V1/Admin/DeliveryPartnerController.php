<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Exceptions\ConflictException;
use App\Http\Controllers\Controller;
use App\Http\Requests\ProvisionDeliveryPartnerRequest;
use App\Http\Requests\UpdateDeliveryPartnerApprovalRequest;
use App\Models\CustomerUser;
use App\Models\DeliveryPartner;
use App\Models\DeliveryPartnerUser;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class DeliveryPartnerController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => DeliveryPartner::query()
                ->with('user:id,name,email,is_active')
                ->orderByDesc('id')
                ->paginate(20),
        ]);
    }

    public function store(ProvisionDeliveryPartnerRequest $request): JsonResponse
    {
        $partner = DB::transaction(function () use ($request): DeliveryPartner {
            $customer = CustomerUser::query()
                ->lockForUpdate()
                ->findOrFail($request->integer('user_id'));

            if (! $customer->is_active) {
                abort(
                    Response::HTTP_UNPROCESSABLE_ENTITY,
                    'Inactive customers cannot be provisioned as delivery partners.'
                );
            }

            if (DeliveryPartnerUser::query()->where('email', $customer->email)->exists()) {
                throw new ConflictException('A delivery partner account already exists for this email.');
            }

            $partnerUser = DeliveryPartnerUser::create([
                'name' => $customer->name,
                'email' => $customer->email,
                'phone' => $customer->phone,
                'password' => $customer->password,
                'is_active' => $customer->is_active,
            ]);

            return DeliveryPartner::create([
                'user_id' => $partnerUser->id,
                'is_approved' => false,
                'is_active' => true,
                'is_available' => false,
            ])->load('user:id,name,email,is_active');
        });

        return response()->json(['data' => $partner], Response::HTTP_CREATED);
    }

    public function updateApproval(
        UpdateDeliveryPartnerApprovalRequest $request,
        DeliveryPartner $deliveryPartner
    ): JsonResponse {
        $approved = $request->boolean('approved');

        $partner = DB::transaction(function () use ($approved, $deliveryPartner, $request): DeliveryPartner {
            $partner = DeliveryPartner::query()
                ->lockForUpdate()
                ->findOrFail($deliveryPartner->id);

            $partner->is_approved = $approved;
            $partner->approved_at = $approved ? now() : null;
            $partner->approved_by = $approved ? $request->user()->id : null;

            if (! $approved) {
                $partner->is_available = false;
            }

            $partner->save();

            return $partner->load('user:id,name,email,is_active', 'approver:id,name,email');
        });

        return response()->json(['data' => $partner]);
    }
}
