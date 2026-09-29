<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\GoogleLoginRequest;
use App\Models\User;
use App\Services\Auth\GoogleCredentialVerifier;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class AuthController extends Controller
{
    public function google(
        GoogleLoginRequest $request,
        GoogleCredentialVerifier $verifier,
    ): JsonResponse {
        try {
            $identity = $verifier->verify($request->string('credential')->toString());
        } catch (RuntimeException) {
            return response()->json([
                'error' => [
                    'code' => 'INVALID_GOOGLE_CREDENTIAL',
                    'message' => 'The Google credential could not be verified.',
                ],
            ], 401);
        }

        $user = DB::transaction(function () use ($identity): User {
            $user = User::where('google_subject', $identity['sub'])
                ->lockForUpdate()
                ->first();

            if ($user === null) {
                return User::create([
                    'google_subject' => $identity['sub'],
                    'name' => $identity['name'],
                    'email' => $identity['email'],
                    'role' => 'CUSTOMER',
                    'is_active' => true,
                ]);
            }

            if (! $user->is_active) {
                return $user;
            }

            $updates = [
                'name' => $identity['name'],
                'email' => $identity['email'],
            ];

            $user->fill($updates);

            if ($user->isDirty()) {
                $user->save();
            }

            return $user;
        });

        if (! $user->is_active) {
            return response()->json([
                'error' => [
                    'code' => 'ACCOUNT_INACTIVE',
                    'message' => 'This account is inactive.',
                ],
            ], 403);
        }

        $token = $user->createToken('flutter')->plainTextToken;

        return response()->json([
            'data' => [
                'token' => $token,
                'user' => $user,
            ],
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user->is_active) {
            $request->user()->currentAccessToken()?->delete();

            return response()->json([
                'error' => [
                    'code' => 'ACCOUNT_INACTIVE',
                    'message' => 'This account is inactive.',
                ],
            ], 403);
        }

        return response()->json([
            'data' => [
                'user' => $user,
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json([
            'data' => [
                'message' => 'Logged out successfully.',
            ],
        ]);
    }
}
