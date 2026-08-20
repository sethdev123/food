<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FoodItem;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;

class OrderApiController extends Controller
{
    // Customer: get own orders
    public function index(Request $request)
    {
        $orders = Order::with('items.foodItem')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get()
            ->map(fn ($o) => $this->orderResource($o));

        return response()->json($orders);
    }

    // Customer: place an order
    public function store(Request $request)
    {
        $data = $request->validate([
            'items'            => 'required|array|min:1',
            'items.*.food_item_id' => 'required|integer',
            'items.*.quantity' => 'required|integer|min:1',
            'delivery_address' => 'nullable|string|max:500',
            'latitude'         => 'nullable|numeric|between:-90,90',
            'longitude'        => 'nullable|numeric|between:-180,180',
            'payment_method'   => 'nullable|string|max:50',
            'coupon_code'      => 'nullable|string|max:50',
            'discount_amount'  => 'nullable|numeric|min:0',
            'total_amount'     => 'nullable|numeric|min:0',
        ]);

        $calculatedTotal = 0;
        $foodItems = [];
        foreach ($data['items'] as $item) {
            $food = FoodItem::find($item['food_item_id']);
            if ($food) {
                $foodItems[] = ['food' => $food, 'quantity' => $item['quantity']];
                $calculatedTotal += $food->price * $item['quantity'];
            } else {
                $foodItems[] = ['food' => null, 'quantity' => $item['quantity'], 'fallback_id' => $item['food_item_id']];
            }
        }

        $discount = (float) ($data['discount_amount'] ?? 0);
        $finalTotal = max(0, $calculatedTotal - $discount);

        $order = Order::create([
            'user_id'          => $request->user()->id,
            'total_price'      => $finalTotal,
            'status'           => 'pending',
            'delivery_address' => $data['delivery_address'] ?? null,
            'latitude'         => $data['latitude'] ?? null,
            'longitude'        => $data['longitude'] ?? null,
            'payment_method'   => $data['payment_method'] ?? 'cash',
            'coupon_code'      => $data['coupon_code'] ?? null,
            'discount_amount'  => $discount,
        ]);

        foreach ($foodItems as $entry) {
            if ($entry['food']) {
                OrderItem::create([
                    'order_id'     => $order->id,
                    'food_item_id' => $entry['food']->id,
                    'quantity'     => $entry['quantity'],
                    'price'        => $entry['food']->price,
                ]);
            }
        }

        $order->load('items.foodItem');

        return response()->json($this->orderResource($order), 201);
    }

    // Seller: view orders that contain their food items
    public function sellerOrders(Request $request)
    {
        $sellerId = $request->user()->id;

        $orders = Order::with(['items.foodItem', 'user:id,name,email'])
            ->whereHas('items.foodItem', fn ($q) => $q->where('user_id', $sellerId))
            ->latest()
            ->get()
            ->map(function ($order) use ($sellerId) {
                $res = $this->orderResource($order);
                $res['customer_name'] = $order->user?->name ?? 'Unknown';
                $res['customer_email'] = $order->user?->email ?? '';
                // Filter items to only show seller's items
                $res['items'] = $order->items
                    ->filter(fn ($item) => $item->foodItem?->user_id === $sellerId)
                    ->values()
                    ->map(fn ($item) => [
                        'name'     => $item->foodItem?->name ?? 'Deleted item',
                        'quantity' => $item->quantity,
                        'price'    => (float) $item->price,
                    ]);
                return $res;
            });

        return response()->json($orders);
    }

    // Sync local orders from device to backend
    public function sync(Request $request)
    {
        $data = $request->validate([
            'orders'            => 'required|array',
            'orders.*.id'       => 'required|string',
            'orders.*.items'    => 'required|array',
            'orders.*.totalAmount' => 'required|numeric|min:0',
            'orders.*.paymentMethod' => 'nullable|string|max:50',
            'orders.*.date'       => 'nullable|string',
            'orders.*.deliveryAddress' => 'nullable|string|max:500',
            'orders.*.latitude'    => 'nullable|numeric|between:-90,90',
            'orders.*.longitude'   => 'nullable|numeric|between:-180,180',
        ]);

        $synced = [];

        foreach ($data['orders'] as $orderData) {
            $user = $request->user();

            $order = Order::create([
                'user_id'          => $user->id,
                'total_price'      => $orderData['totalAmount'],
                'status'           => 'pending',
                'delivery_address' => $orderData['deliveryAddress'] ?? null,
                'latitude'         => $orderData['latitude'] ?? null,
                'longitude'        => $orderData['longitude'] ?? null,
                'payment_method'   => $orderData['paymentMethod'] ?? 'cash',
                'coupon_code'      => null,
                'discount_amount'  => 0,
            ]);

            foreach ($orderData['items'] as $item) {
                $food = null;
                if (!empty($item['foodItem']['id'])) {
                    $foodId = is_numeric($item['foodItem']['id']) ? (int) $item['foodItem']['id'] : null;
                    if ($foodId) {
                        $food = FoodItem::find($foodId);
                    }
                }

                $price = $item['foodItem']['price'] ?? 0;
                if (!is_numeric($price)) $price = 0;

                OrderItem::create([
                    'order_id'     => $order->id,
                    'food_item_id' => $food?->id,
                    'quantity'     => $item['quantity'] ?? 1,
                    'price'        => (float) $price,
                ]);
            }

            $order->load('items.foodItem');
            $res = $this->orderResource($order);
            $res['customer_name'] = $user->name;
            $res['customer_email'] = $user->email;
            $synced[] = $res;
        }

        return response()->json($synced, 201);
    }

    // Admin: view all orders (across all users)
    public function allOrders(Request $request)
    {
        $orders = Order::with(['items.foodItem', 'user:id,name,email'])
            ->latest()
            ->get()
            ->map(function ($order) {
                $res = $this->orderResource($order);
                $res['customer_name'] = $order->user?->name ?? 'Unknown';
                $res['customer_email'] = $order->user?->email ?? '';
                return $res;
            });

        return response()->json($orders);
    }

    private function orderResource(Order $order): array
    {
        return [
            'id'               => $order->id,
            'status'           => $order->status,
            'total_price'      => (float) $order->total_price,
            'discount_amount'  => (float) $order->discount_amount,
            'coupon_code'      => $order->coupon_code,
            'delivery_address' => $order->delivery_address,
            'latitude'         => $order->latitude ? (float) $order->latitude : null,
            'longitude'        => $order->longitude ? (float) $order->longitude : null,
            'payment_method'   => $order->payment_method,
            'created_at'       => $order->created_at?->toDateTimeString(),
            'items'            => $order->items->map(fn ($item) => [
                'food_item_id' => $item->food_item_id,
                'name'         => $item->foodItem?->name ?? 'Deleted item',
                'quantity'     => $item->quantity,
                'price'        => (float) $item->price,
            ]),
        ];
    }
}
