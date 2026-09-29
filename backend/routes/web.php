<?php

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\OrderController;
use App\Http\Controllers\Admin\OperationsController;
use App\Http\Middleware\EnsureAdminWebUser;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect()->route('admin.login'));

Route::middleware('guest:web')->group(function (): void {
    Route::get('/admin/login', [AuthController::class, 'create'])->name('admin.login');
    Route::post('/admin/login', [AuthController::class, 'store'])
        ->middleware('throttle:admin-login')
        ->name('admin.login.store');
});

Route::middleware(EnsureAdminWebUser::class)->group(function (): void {
    Route::get('/admin', DashboardController::class)->name('admin.dashboard');
    Route::get('/admin/orders', [OrderController::class, 'index'])->name('admin.orders.index');
    Route::get('/admin/customers', [OperationsController::class, 'customers'])->name('admin.customers.index');
    Route::get('/admin/delivery-partners', [OperationsController::class, 'deliveryPartners'])->name('admin.delivery-partners.index');
    Route::get('/admin/assignments', [OperationsController::class, 'assignments'])->name('admin.assignments.index');
    Route::get('/admin/invoices', [OperationsController::class, 'invoices'])->name('admin.invoices.index');
    Route::get('/admin/orders/{order}', [OrderController::class, 'show'])->name('admin.orders.show');
    Route::post('/admin/orders/{order}/status', [OrderController::class, 'updateStatus'])->name('admin.orders.status');
    Route::post('/admin/logout', [AuthController::class, 'destroy'])->name('admin.logout');
});
