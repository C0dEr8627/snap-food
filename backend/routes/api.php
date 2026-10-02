<?php

use App\Http\Controllers\Api\V1\Admin\DeliveryPartnerController;
use App\Http\Controllers\Api\V1\Admin\UserController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\AddressController;
use App\Http\Controllers\Api\V1\Catalogue\CategoryController;
use App\Http\Controllers\Api\V1\Catalogue\ProductController;
use App\Http\Controllers\Api\V1\Delivery\DeliveryLocationController;
use App\Http\Controllers\Api\V1\Delivery\DeliveryPartnerOrderController;
use App\Http\Controllers\Api\V1\HealthController;
use App\Http\Controllers\Api\V1\Orders\AdminOrderAssignmentController;
use App\Http\Controllers\Api\V1\Orders\AdminInvoiceController;
use App\Http\Controllers\Api\V1\Orders\AdminOrderController;
use App\Http\Controllers\Api\V1\Orders\InvoiceController;
use App\Http\Controllers\Api\V1\Orders\OrderController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class)->name('api.v1.health');

Route::get('/products/{product}/image', [ProductController::class, 'image'])
    ->name('api.v1.products.image');

Route::post('/auth/google', [AuthController::class, 'google'])
    ->middleware('throttle:auth-google')
    ->name('api.v1.auth.google');

Route::post('/auth/register', [AuthController::class, 'registerCustomer'])
    ->middleware('throttle:auth-google')
    ->name('api.v1.auth.register');

Route::post('/auth/login', [AuthController::class, 'customerPassword'])
    ->middleware('throttle:auth-google')
    ->name('api.v1.auth.login');

Route::post('/admin/auth/password', [AuthController::class, 'adminPassword'])
    ->middleware('throttle:admin-login')
    ->name('api.v1.admin.auth.password');

Route::post('/admin/auth/google', [AuthController::class, 'adminGoogle'])
    ->middleware('throttle:admin-login')
    ->name('api.v1.admin.auth.google');

Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('/me', [AuthController::class, 'me'])->name('api.v1.me');
    Route::get('/addresses', [AddressController::class, 'index'])->middleware('role:CUSTOMER')->name('api.v1.addresses.index');
    Route::post('/addresses', [AddressController::class, 'store'])->middleware('role:CUSTOMER')->name('api.v1.addresses.store');
    Route::delete('/addresses/{address}', [AddressController::class, 'destroy'])->middleware('role:CUSTOMER')->name('api.v1.addresses.destroy');
    Route::post('/auth/logout', [AuthController::class, 'logout'])->name('api.v1.auth.logout');

    Route::prefix('consumer')->name('api.v1.consumer.')->middleware('role:CUSTOMER')->group(function (): void {
        Route::get('/categories', [CategoryController::class, 'index'])->name('categories.index');
        Route::get('/categories/{category}', [CategoryController::class, 'show'])->name('categories.show');
        Route::get('/products', [ProductController::class, 'index'])->name('products.index');
        Route::get('/products/{product}', [ProductController::class, 'show'])->name('products.show');
        Route::get('/orders', [OrderController::class, 'index'])->name('orders.index');
        Route::post('/orders', [OrderController::class, 'store'])->name('orders.store');
        Route::get('/orders/{order}', [OrderController::class, 'show'])->name('orders.show');
        Route::get('/orders/{order}/tracking', [DeliveryLocationController::class, 'show'])->name('orders.tracking');
        Route::get('/orders/{order}/invoice', [InvoiceController::class, 'show'])->name('orders.invoice');
    });

    Route::prefix('delivery')->name('api.v1.delivery.')->middleware('role:DELIVERY_PARTNER')->group(function (): void {
        Route::get('/assignments', [DeliveryPartnerOrderController::class, 'index'])->name('assignments.index');
        Route::patch('/assignments/{assignment}/status', [DeliveryPartnerOrderController::class, 'updateStatus'])->name('assignments.status');
        Route::post('/assignments/{assignment}/location', [DeliveryLocationController::class, 'store'])->name('assignments.location');
    });

    Route::prefix('admin')->name('api.v1.admin.')->middleware('role:ADMIN')->group(function (): void {
        Route::get('/invoices', [AdminInvoiceController::class, 'index'])->name('invoices.index');
        Route::get('/orders', [AdminOrderController::class, 'index'])->name('orders.index');
        Route::patch('/orders/{order}/status', [AdminOrderController::class, 'updateStatus'])->name('orders.status');
        Route::post('/orders/{order}/assignment', [AdminOrderAssignmentController::class, 'store'])->name('orders.assignment');
        Route::get('/orders/{order}/tracking', [DeliveryLocationController::class, 'show'])->name('orders.tracking');
        Route::get('/orders/{order}/invoice', [InvoiceController::class, 'show'])->name('orders.invoice');
        Route::get('/delivery-partners', [DeliveryPartnerController::class, 'index'])->name('delivery-partners.index');
        Route::get('/users', [UserController::class, 'index'])->name('users.index');
        Route::post('/delivery-partners', [DeliveryPartnerController::class, 'store'])->name('delivery-partners.store');
        Route::patch('/delivery-partners/{deliveryPartner}/approval', [DeliveryPartnerController::class, 'updateApproval'])->name('delivery-partners.approval');
        Route::get('/categories', [CategoryController::class, 'index'])->name('categories.index');
        Route::get('/categories/{category}', [CategoryController::class, 'show'])->name('categories.show');
        Route::post('/categories', [CategoryController::class, 'store'])->name('categories.store');
        Route::patch('/categories/{category}', [CategoryController::class, 'update'])->name('categories.update');
        Route::delete('/categories/{category}', [CategoryController::class, 'destroy'])->name('categories.destroy');
        Route::get('/products', [ProductController::class, 'index'])->name('products.index');
        Route::get('/products/{product}', [ProductController::class, 'show'])->name('products.show');
        Route::post('/products', [ProductController::class, 'store'])->name('products.store');
        Route::patch('/products/{product}', [ProductController::class, 'update'])->name('products.update');
        Route::post('/products/{product}/image', [ProductController::class, 'uploadImage'])->name('products.image');
        Route::delete('/products/{product}', [ProductController::class, 'destroy'])->name('products.destroy');
    });
});
