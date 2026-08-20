<?php

use App\Http\Controllers\Api\AuthApiController;
use App\Http\Controllers\Api\FoodApiController;
use App\Http\Controllers\Api\OrderApiController;
use App\Http\Controllers\Api\SellerApiController;
use Illuminate\Support\Facades\Route;

// ---------------------------------------------------------------------------
// Public endpoints (no auth required)
// ---------------------------------------------------------------------------
Route::post('/register', [AuthApiController::class, 'register']);
Route::post('/login',    [AuthApiController::class, 'login']);
Route::get('/foods',     [FoodApiController::class, 'index']);
Route::get('/foods/{id}', [FoodApiController::class, 'show']);

// ---------------------------------------------------------------------------
// Authenticated endpoints (any role)
// ---------------------------------------------------------------------------
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthApiController::class, 'logout']);
    Route::get('/user',    [AuthApiController::class, 'profile']);
    Route::put('/user',    [AuthApiController::class, 'updateProfile']);

    Route::get('/orders',       [OrderApiController::class, 'index']);
    Route::post('/orders',      [OrderApiController::class, 'store']);
    Route::get('/orders/all',   [OrderApiController::class, 'allOrders']);
    Route::post('/orders/sync', [OrderApiController::class, 'sync']);

    // -----------------------------------------------------------------------
    // Seller-only endpoints
    // -----------------------------------------------------------------------
    Route::middleware('seller')->group(function () {
        Route::get('/seller/foods',        [FoodApiController::class,  'sellerIndex']);
        Route::post('/seller/foods',       [FoodApiController::class,  'sellerStore']);
        Route::put('/seller/foods/{id}',   [FoodApiController::class,  'sellerUpdate']);
        Route::delete('/seller/foods/{id}',[FoodApiController::class,  'sellerDestroy']);
        Route::get('/seller/orders',       [OrderApiController::class, 'sellerOrders']);
        Route::get('/seller/stats',        [SellerApiController::class,'stats']);
    });

    // -----------------------------------------------------------------------
    // Admin-only endpoints
    // -----------------------------------------------------------------------
    Route::middleware('can:isAdmin')->group(function () {
        Route::patch('/admin/orders/{order}/status', function (\App\Models\Order $order, \Illuminate\Http\Request $request) {
            $request->validate(['status' => 'required|in:pending,completed,cancelled']);
            $order->update(['status' => $request->status]);
            return response()->json(['message' => 'Order status updated.', 'order' => $order]);
        });
    });
});
