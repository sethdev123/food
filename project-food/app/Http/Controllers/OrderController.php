<?php

namespace App\Http\Controllers;

use App\Models\FoodItem;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'food_item_id' => 'required|exists:food_items,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $foodItem = FoodItem::find($request->food_item_id);

        $order = Order::create([
            'user_id'          => Auth::id(),
            'total_price'      => $foodItem->price * $request->quantity,
            'status'           => 'pending',
            'delivery_address' => $request->delivery_address,
            'latitude'         => $request->latitude,
            'longitude'        => $request->longitude,
        ]);

        OrderItem::create([
            'order_id' => $order->id,
            'food_item_id' => $foodItem->id,
            'quantity' => $request->quantity,
            'price' => $foodItem->price,
        ]);

        return redirect('/dashboard')->with('success', 'Order placed successfully!');
    }
}
