<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if ($user === null) {
            return response()->json([
                'message' => 'Authentication is required.',
                'errors' => (object) [],
                'code' => 'UNAUTHORIZED',
            ], 401);
        }

        if (! $user->is_active) {
            return response()->json([
                'message' => 'This account is inactive.',
                'errors' => (object) [],
                'code' => 'ACCOUNT_INACTIVE',
            ], 403);
        }

        if (! $user->hasAnyRole($roles)) {
            return response()->json([
                'message' => 'You are not authorized to perform this action.',
                'errors' => (object) [],
                'code' => 'FORBIDDEN',
            ], 403);
        }

        return $next($request);
    }
}
