<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\StoreAddressRequest;
use App\Models\Address;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AddressController
{
    public function index(Request $request): JsonResponse
    {
        $addresses = Address::query()
            ->where('user_id', $request->user()->id)
            ->latest('updated_at')
            ->get();

        return response()->json(['data' => $addresses]);
    }

    public function store(StoreAddressRequest $request): JsonResponse
    {
        $address = Address::create([
            ...$request->validated(),
            'user_id' => $request->user()->id,
            'country' => $request->validated('country') ?: 'India',
        ]);

        return response()->json(['data' => $address], 201);
    }

    public function destroy(Request $request, Address $address): JsonResponse
    {
        abort_unless((int) $address->user_id === (int) $request->user()->id, 404);
        $address->delete();

        return response()->json(['data' => ['deleted' => true]]);
    }
}
