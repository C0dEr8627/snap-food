<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\HealthController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class)->name('api.v1.health');

Route::post('/auth/google', [AuthController::class, 'google'])
    ->name('api.v1.auth.google');

Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('/me', [AuthController::class, 'me'])->name('api.v1.me');
    Route::post('/auth/logout', [AuthController::class, 'logout'])->name('api.v1.auth.logout');
});
