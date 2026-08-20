<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Attributes\Fillable;

#[Fillable(['order_id', 'food_item_id', 'quantity', 'price'])]
class OrderItem extends Model
{
    /**
     * Get the order that owns the item.
     */
    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Get the food item.
     */
    public function foodItem()
    {
        return $this->belongsTo(FoodItem::class);
    }
}
