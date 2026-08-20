<?php

namespace App\Http\Controllers;

use App\Models\FoodItem;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    public function index()
    {
        $user = Auth::user();

        if ($user->role === 'admin') {
            $orders        = Order::with(['user', 'items.foodItem'])->latest()->get();
            $totalSales    = $orders->whereIn('status', ['completed', 'accepted'])->sum('total_price');
            $pendingOrders = $orders->whereIn('status', ['pending', 'accepted'])->count();
            $totalFoods    = FoodItem::count();
            return view('dashboard.admin', compact('orders', 'totalSales', 'pendingOrders', 'totalFoods'));

        } elseif ($user->role === 'seller') {
            // Sellers manage ALL food items
            $myFoods = FoodItem::with('seller')->latest()->get();

            $orders  = Order::with(['items.foodItem', 'user'])->latest()->get();

            $totalRevenue  = $orders->whereIn('status', ['completed', 'accepted'])->sum('total_price');
            $totalOrders   = $orders->count();
            $pendingOrders = $orders->whereIn('status', ['pending', 'accepted'])->count();
            $totalFoods    = $myFoods->count();

            return view('dashboard.seller', compact(
                'myFoods', 'orders', 'totalRevenue', 'totalOrders', 'pendingOrders', 'totalFoods'
            ));

        } else {
            $orders = Order::with('items.foodItem')->where('user_id', $user->id)->latest()->get();
            return view('dashboard.user', compact('orders'));
        }
    }

    public function updateOrderStatus(Order $order, Request $request)
    {
        $request->validate(['status' => 'required|in:pending,accepted,completed,cancelled']);
        $order->update(['status' => $request->status]);
        return back()->with('success', 'Order status updated!');
    }

    public function showOrder(Order $order)
    {
        $order->load(['items.foodItem', 'user']);

        // Filter items to only show seller's items if current user is a seller
        if (Auth::user()->role === 'seller') {
            $order->items = $order->items->filter(
                fn ($item) => $item->foodItem && $item->foodItem->user_id === Auth::id()
            );
        }

        return view('dashboard.order-detail', compact('order'));
    }

    public function acceptOrder(Order $order)
    {
        if ($order->status === 'pending') {
            $order->update(['status' => 'accepted']);
            return response()->json(['success' => true]);
        }
        return response()->json(['success' => false, 'message' => 'Order is not pending'], 400);
    }
}
