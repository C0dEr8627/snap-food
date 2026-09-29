<?php

use App\Exceptions\ConflictException;
use App\Exceptions\OrderStateConflictException;
use App\Http\Middleware\EnsureUserHasRole;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnauthorizedHttpException;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\Exceptions\ThrottleRequestsException;
use Throwable;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        apiPrefix: 'api/v1',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'role' => EnsureUserHasRole::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(function (Request $request, Throwable $e): bool {
            return $request->is('api/v1/*') || $request->expectsJson();
        });

        $exceptions->render(function (ConflictException $e, Request $request) {
            if (! $request->is('api/v1/*')) return null;
            return response()->json(['message' => $e->getMessage(), 'errors' => (object) [], 'code' => 'CONFLICT'], 409);
        });

        $exceptions->render(function (OrderStateConflictException $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => $e->getMessage(),
                'errors' => (object) [],
                'code' => 'ORDER_STATE_CONFLICT',
            ], 409);
        });

        $exceptions->render(function (ValidationException $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $e->errors(),
                'code' => 'VALIDATION_FAILED',
            ], 422);
        });

        $exceptions->render(function (AuthenticationException $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => 'Authentication is required.',
                'errors' => (object) [],
                'code' => 'UNAUTHORIZED',
            ], 401);
        });

        $exceptions->render(function (AuthorizationException $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => 'You are not authorized to perform this action.',
                'errors' => (object) [],
                'code' => 'FORBIDDEN',
            ], 403);
        });

        $exceptions->render(function (AccessDeniedHttpException $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => 'You are not authorized to perform this action.',
                'errors' => (object) [],
                'code' => 'FORBIDDEN',
            ], 403);
        });

        $exceptions->render(function (ThrottleRequestsException $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => 'Too many requests. Please try again later.',
                'errors' => (object) [],
                'code' => 'RATE_LIMITED',
            ], 429, $e->getHeaders());
        });

        $exceptions->render(function (NotFoundHttpException $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => 'The requested resource was not found.',
                'errors' => (object) [],
                'code' => 'NOT_FOUND',
            ], 404);
        });

        $exceptions->render(function (MethodNotAllowedHttpException $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => 'The requested method is not allowed.',
                'errors' => (object) [],
                'code' => 'METHOD_NOT_ALLOWED',
            ], 405);
        });

        $exceptions->render(function (UnauthorizedHttpException $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => 'Authentication is required.',
                'errors' => (object) [],
                'code' => 'UNAUTHORIZED',
            ], 401);
        });

        $exceptions->render(function (Throwable $e, Request $request) {
            if (! $request->is('api/v1/*')) {
                return null;
            }

            return response()->json([
                'message' => 'An unexpected server error occurred.',
                'errors' => (object) [],
                'code' => 'SERVER_ERROR',
            ], 500);
        });
    })
    ->create();
