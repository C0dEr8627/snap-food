<?php

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
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
    Route::post('/admin/logout', [AuthController::class, 'destroy'])->name('admin.logout');
});
