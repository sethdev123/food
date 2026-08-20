<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FoodItem;
use App\Models\Order;
use Illuminate\Http\Request;

class SellerApiController extends Controller
{
    public function stats(Request $request)
    {
        $sellerId = $request->user()->id;

        $myFoodIds = FoodItem::where('user_id', $sellerId)->pluck('id');

        $orders = Order::whereHas('items', fn ($q) => $q->whereIn('food_item_id', $myFoodIds))->get();

        $totalRevenue  = $orders->where('status', 'completed')->sum('total_price');
        $totalOrders   = $orders->count();
        $pendingOrders = $orders->where('status', 'pending')->count();
        $totalFoods    = $myFoodIds->count();

        return response()->json([
            'total_revenue'  => (float) $totalRevenue,
            'total_orders'   => $totalOrders,
            'pending_orders' => $pendingOrders,
            'total_foods'    => $totalFoods,
        ]);
    }
}
