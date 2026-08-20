<?php

namespace Database\Seeders;

use App\Models\FoodItem;
use Illuminate\Database\Seeder;

class FoodSeeder extends Seeder
{
    public function run(): void
    {
        $foods = [
            [
                'name' => 'Signature Beef Burger',
                'description' => 'Premium wagyu beef patty with caramelized onions, truffle mayo, and aged cheddar.',
                'price' => 14.99,
                'image_url' => 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=800&auto=format&fit=crop',
            ],
            [
                'name' => 'Italian Pepperoni Pizza',
                'description' => 'Hand-tossed sourdough crust topped with spicy pepperoni and fresh buffalo mozzarella.',
                'price' => 18.50,
                'image_url' => 'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=800&auto=format&fit=crop',
            ],
            [
                'name' => 'Wild Salmon Sushi Set',
                'description' => 'Fresh Alaskan salmon nigiri and avocado rolls served with premium wasabi.',
                'price' => 22.00,
                'image_url' => 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?q=80&w=800&auto=format&fit=crop',
            ],
            [
                'name' => 'Crunchy Thai Salad',
                'description' => 'Fresh garden greens with grilled chicken, peanuts, and a spicy lime dressing.',
                'price' => 12.75,
                'image_url' => 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800&auto=format&fit=crop',
            ],
            [
                'name' => 'Creamy Fettuccine Alfredo',
                'description' => 'Classic Italian pasta with rich parmesan cream sauce and fresh parsley.',
                'price' => 16.50,
                'image_url' => 'https://images.unsplash.com/photo-1645112481338-356cda07504e?q=80&w=800&auto=format&fit=crop', // Re-using a pasta-like search if possible
            ],
            [
                'name' => 'Crispy Buffalo Wings',
                'description' => 'Jumbo wings tossed in spicy buffalo sauce, served with blue cheese dip.',
                'price' => 13.50,
                'image_url' => 'https://images.unsplash.com/photo-1567620905732-2d1ec7bb7445?q=80&w=800&auto=format&fit=crop',
            ],
            [
                'name' => 'Loaded Nachos Grande',
                'description' => 'Corn tortillas with melted cheese, jalapenos, guacamole, and sour cream.',
                'price' => 11.99,
                'image_url' => 'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?q=80&w=800&auto=format&fit=crop',
            ],
            [
                'name' => 'Dark Chocolate Lava Cake',
                'description' => 'Warm chocolate cake with a molten center, served with vanilla bean ice cream.',
                'price' => 8.99,
                'image_url' => 'https://images.unsplash.com/photo-1624353365286-3f8d62ffff51?q=80&w=800&auto=format&fit=crop',
            ],
        ];

        foreach ($foods as $food) {
            FoodItem::create($food);
        }
    }
}
