<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Exceptions\ConflictException;
use App\Http\Controllers\Controller;
use App\Http\Requests\ProvisionDeliveryPartnerRequest;
use App\Http\Requests\UpdateDeliveryPartnerApprovalRequest;
use App\Models\DeliveryPartner;
use App\Models\DeliveryPartnerUser;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
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
            $partnerUser = DeliveryPartnerUser::create([
                'name' => $request->string('name')->toString(),
                'email' => strtolower(trim($request->string('email')->toString())),
                'phone' => $request->filled('phone') ? trim($request->string('phone')->toString()) : null,
                'password' => Hash::make($request->string('password')->toString()),
                'is_active' => true,
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
            $partner->is_available = $approved && $partner->is_active;

            $partner->save();

            return $partner->load('user:id,name,email,is_active', 'approver:id,name,email');
        });

        return response()->json(['data' => $partner]);
    }
}
