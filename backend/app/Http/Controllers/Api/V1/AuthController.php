<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\GoogleLoginRequest;
use App\Models\AdminUser;
use App\Models\CustomerUser;
use App\Models\DeliveryPartnerUser;
use App\Services\Auth\GoogleCredentialVerifier;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class AuthController extends Controller
{
    public function registerCustomer(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'min:2', 'max:120'],
            'email' => ['required', 'email', 'max:255', 'unique:customer_users,email'],
            'phone' => ['required', 'regex:/^\\+91[6-9][0-9]{9}$/', 'unique:customer_users,phone'],
            'password' => ['required', 'string', 'min:8', 'max:255', 'confirmed'],
        ]);

        $user = CustomerUser::create([
            'name' => trim($validated['name']),
            'email' => strtolower(trim($validated['email'])),
            'phone' => $validated['phone'],
            'password' => Hash::make($validated['password']),
            'is_active' => true,
        ]);

        return response()->json([
            'data' => [
                'token' => $user->createToken('flutter')->plainTextToken,
                'user' => $user,
            ],
        ], 201);
    }

    public function customerPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string', 'min:8', 'max:255'],
        ]);

        $user = CustomerUser::where('email', strtolower(trim($validated['email'])))->first();

        if (
            $user === null
            || ! $user->is_active
            || $user->password === null
            || ! Hash::check($validated['password'], $user->password)
        ) {
            return response()->json([
                'message' => 'The email or password is incorrect.',
                'errors' => (object) [],
                'code' => 'INVALID_CREDENTIALS',
            ], 401);
        }

        return $this->issueToken($user);
    }

    public function google(
        GoogleLoginRequest $request,
        GoogleCredentialVerifier $verifier,
    ): JsonResponse {
        try {
            $identity = $verifier->verify($request->string('credential')->toString());
        } catch (RuntimeException) {
            Log::warning('Google credential verification failed.', [
                'route' => $request->route()?->getName(),
            ]);

            return response()->json([
                'message' => 'The Google credential could not be verified.',
                'errors' => (object) [],
                'code' => 'INVALID_GOOGLE_CREDENTIAL',
            ], 401);
        }

        $user = DB::transaction(function () use ($identity): CustomerUser {
            $user = CustomerUser::where('google_subject', $identity['sub'])
                ->lockForUpdate()
                ->first();

            if ($user === null) {
                return CustomerUser::create([
                    'google_subject' => $identity['sub'],
                    'name' => $identity['name'],
                    'email' => $identity['email'],
                    'is_active' => true,
                ]);
            }

            if (! $user->is_active) {
                return $user;
            }

            $user->fill([
                'name' => $identity['name'],
                'email' => $identity['email'],
            ]);

            if ($user->isDirty()) {
                $user->save();
            }

            return $user;
        });

        return $this->issueTokenOrReject($user);
    }

    public function deliveryPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string', 'min:8', 'max:255'],
        ]);

        $user = DeliveryPartnerUser::where('email', strtolower(trim($validated['email'])))->first();

        if (
            $user === null
            || ! $user->is_active
            || $user->password === null
            || ! Hash::check($validated['password'], $user->password)
        ) {
            return response()->json([
                'message' => 'The delivery partner email or password is incorrect.',
                'errors' => (object) [],
                'code' => 'INVALID_CREDENTIALS',
            ], 401);
        }

        $partner = $user->deliveryPartner;

        if ($partner === null || ! $partner->is_active) {
            return response()->json([
                'message' => 'This delivery partner account is not active.',
                'errors' => (object) [],
                'code' => 'DELIVERY_PARTNER_INACTIVE',
            ], 403);
        }

        if (! $partner->is_approved) {
            return response()->json([
                'message' => 'Your delivery partner account is awaiting approval.',
                'errors' => (object) [],
                'code' => 'DELIVERY_PARTNER_NOT_APPROVED',
            ], 403);
        }

        return $this->issueToken($user);
    }

    public function adminPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string', 'min:8', 'max:255'],
        ]);

        $user = AdminUser::where('email', $validated['email'])->first();

        if ($user === null) {
            $bootstrapEmail = config('services.google.admin_bootstrap_email');
            $bootstrapPassword = env('ADMIN_BOOTSTRAP_PASSWORD');

            if (
                is_string($bootstrapEmail)
                && $bootstrapEmail !== ''
                && strcasecmp($validated['email'], $bootstrapEmail) === 0
                && is_string($bootstrapPassword)
                && $bootstrapPassword !== ''
                && hash_equals($bootstrapPassword, $validated['password'])
                && ! AdminUser::exists()
            ) {
                $user = AdminUser::create([
                    'name' => 'Admin',
                    'email' => $bootstrapEmail,
                    'password' => Hash::make($bootstrapPassword),
                    'is_active' => true,
                ]);
            }
        }

        if (
            $user === null
            || ! $user->is_active
            || $user->password === null
            || ! Hash::check($validated['password'], $user->password)
        ) {
            return response()->json([
                'message' => 'The email or password is incorrect.',
                'errors' => (object) [],
                'code' => 'INVALID_CREDENTIALS',
            ], 401);
        }

        return $this->issueToken($user);
    }

    public function adminGoogle(
        GoogleLoginRequest $request,
        GoogleCredentialVerifier $verifier,
    ): JsonResponse {
        try {
            $identity = $verifier->verify($request->string('credential')->toString());
        } catch (RuntimeException) {
            Log::warning('Admin Google credential verification failed.', [
                'route' => $request->route()?->getName(),
            ]);

            return response()->json([
                'message' => 'The Google credential could not be verified.',
                'errors' => (object) [],
                'code' => 'INVALID_GOOGLE_CREDENTIAL',
            ], 401);
        }

        $user = AdminUser::where('google_subject', $identity['sub'])->first();

        if ($user === null && app()->environment('local')) {
            $bootstrapEmail = config('services.google.admin_bootstrap_email');

            if (
                is_string($bootstrapEmail)
                && $bootstrapEmail !== ''
                && is_string($identity['email'])
                && strcasecmp($identity['email'], $bootstrapEmail) === 0
            ) {
                $user = AdminUser::where('email', $bootstrapEmail)->first();

                if ($user !== null && $user->is_active) {
                    $user->forceFill([
                        'google_subject' => $identity['sub'],
                        'name' => $identity['name'],
                        'email' => $identity['email'],
                    ])->save();
                }
            }
        }

        if ($user === null || ! $user->is_active) {
            return response()->json([
                'message' => 'This Google account is not authorized for the admin dashboard.',
                'errors' => (object) [],
                'code' => 'ADMIN_ACCESS_REQUIRED',
            ], 403);
        }

        $user->fill([
            'name' => $identity['name'],
            'email' => $identity['email'],
        ]);

        if ($user->isDirty()) {
            $user->save();
        }

        return $this->issueToken($user);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user->is_active) {
            $request->user()->currentAccessToken()?->delete();

            return response()->json([
                'message' => 'This account is inactive.',
                'errors' => (object) [],
                'code' => 'ACCOUNT_INACTIVE',
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

    private function issueTokenOrReject(Authenticatable $user): JsonResponse
    {
        if (! $user->is_active) {
            return response()->json([
                'message' => 'This account is inactive.',
                'errors' => (object) [],
                'code' => 'ACCOUNT_INACTIVE',
            ], 403);
        }

        return $this->issueToken($user);
    }

    private function issueToken(Authenticatable $user): JsonResponse
    {
        return response()->json([
            'data' => [
                'token' => $user->createToken('flutter')->plainTextToken,
                'user' => $user,
            ],
        ]);
    }
}
