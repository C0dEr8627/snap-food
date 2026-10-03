<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['required', 'string', 'min:2', 'max:120'],
            'phone' => [
                'nullable',
                'string',
                'regex:/^\\+91[6-9][0-9]{9}$/',
                Rule::unique('customer_users', 'phone')->ignore($user->id),
            ],
        ]);

        $user->name = trim($validated['name']);
        $user->phone = isset($validated['phone']) && trim($validated['phone']) !== ''
            ? trim($validated['phone'])
            : null;
        $user->save();

        return response()->json(['data' => ['user' => $user->fresh()]]);
    }
}
