<?php

namespace App\Http\Controllers\Api\V1\Orders;

use App\Http\Requests\AssignOrderRequest;
use App\Models\DeliveryPartnerUser;
use App\Models\Order;
use App\Services\Orders\OrderAssignmentService;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class AdminOrderAssignmentController
{
    public function store(
        AssignOrderRequest $request,
        Order $order,
        OrderAssignmentService $assignmentService
    ): JsonResponse {
        $assignment = $assignmentService->assign(
            $order,
            DeliveryPartnerUser::query()->findOrFail($request->integer('delivery_partner_id')),
            $request->user()
        );

        return response()->json(['data' => $assignment], Response::HTTP_CREATED);
    }
}
