<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\Catalogue\CategoryController;
use App\Http\Controllers\Api\V1\Catalogue\ProductController;
use App\Http\Controllers\Api\V1\HealthController;
use App\Http\Controllers\Api\V1\Orders\OrderController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class)->name('api.v1.health');

Route::post('/auth/google', [AuthController::class, 'google'])
    ->middleware('throttle:auth-google')
    ->name('api.v1.auth.google');

Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('/me', [AuthController::class, 'me'])->name('api.v1.me');
    Route::post('/auth/logout', [AuthController::class, 'logout'])->name('api.v1.auth.logout');

    Route::get('/categories', [CategoryController::class, 'index'])->name('api.v1.categories.index');
    Route::get('/categories/{category}', [CategoryController::class, 'show'])->name('api.v1.categories.show');
    Route::get('/products', [ProductController::class, 'index'])->name('api.v1.products.index');
    Route::get('/products/{product}', [ProductController::class, 'show'])->name('api.v1.products.show');

    Route::get('/orders', [OrderController::class, 'index'])->name('api.v1.orders.index');
    Route::post('/orders', [OrderController::class, 'store'])->name('api.v1.orders.store');
    Route::get('/orders/{order}', [OrderController::class, 'show'])->name('api.v1.orders.show');

    Route::middleware('role:ADMIN')->group(function (): void {
        Route::post('/categories', [CategoryController::class, 'store'])->name('api.v1.categories.store');
        Route::patch('/categories/{category}', [CategoryController::class, 'update'])->name('api.v1.categories.update');
        Route::delete('/categories/{category}', [CategoryController::class, 'destroy'])->name('api.v1.categories.destroy');
        Route::post('/products', [ProductController::class, 'store'])->name('api.v1.products.store');
        Route::patch('/products/{product}', [ProductController::class, 'update'])->name('api.v1.products.update');
        Route::delete('/products/{product}', [ProductController::class, 'destroy'])->name('api.v1.products.destroy');
    });
});
