<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\FoodController;
use App\Http\Controllers\OrderController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    if (auth()->check()) {
        return redirect()->route('dashboard');
    }
    return redirect()->route('login');
});

Route::middleware('guest')->group(function () {
    Route::get('/login',    [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login',   [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register',[AuthController::class, 'register']);
});

Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth');

Route::middleware('auth')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    Route::post('/order', [OrderController::class, 'store']);

    // Food management (seller + admin)
    Route::get('/food/create',       [FoodController::class, 'create']);
    Route::post('/food',             [FoodController::class, 'store']);
    Route::get('/food/{food}/edit',  [FoodController::class, 'edit']);
    Route::patch('/food/{food}',     [FoodController::class, 'update']);
    Route::delete('/food/{food}',    [FoodController::class, 'destroy']);

    // Order detail
    Route::get('/orders/{order}', [DashboardController::class, 'showOrder'])->name('orders.show');

    // Accept order (auto after 3-4s)
    Route::patch('/orders/{order}/accept', [DashboardController::class, 'acceptOrder']);

    // Admin only
    Route::middleware('can:isAdmin')->group(function () {
        Route::patch('/orders/{order}/status', [DashboardController::class, 'updateOrderStatus']);
    });
});
