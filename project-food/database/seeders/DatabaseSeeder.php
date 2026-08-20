<?php

namespace Database\Seeders;

use App\Models\FoodItem;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::truncate();
        FoodItem::truncate();

        // Seller
        $seller = User::create([
            'name'     => 'Best Kitchen',
            'email'    => 'seller@food.com',
            'password' => Hash::make('password'),
            'role'     => 'seller',
        ]);

        // Customer
        User::create([
            'name'     => 'Happy Customer',
            'email'    => 'customer@food.com',
            'password' => Hash::make('password'),
            'role'     => 'user',
        ]);

        // Admin
        User::create([
            'name'     => 'System Admin',
            'email'    => 'admin@food.com',
            'password' => Hash::make('password'),
            'role'     => 'admin',
        ]);

        $foods = [
            // Burgers
            ['name' => 'Classic Beef Burger', 'price' => 12.99, 'category' => 'Burgers', 'description' => 'Juicy prime beef patty, cheddar, lettuce, tomato, house sauce.', 'image_url' => 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Cheese Bacon Burger', 'price' => 14.50, 'category' => 'Burgers', 'description' => 'Double cheese, crispy bacon strips, caramelized onions, BBQ glaze.', 'image_url' => 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Spicy Crispy Chicken Burger', 'price' => 11.99, 'category' => 'Burgers', 'description' => 'Zesty fried chicken breast, spicy mayo, pickles, shredded lettuce.', 'image_url' => 'https://images.unsplash.com/photo-1625813506062-0aeb1d7a094b?auto=format&fit=crop&w=600&q=80'],
            // Pizza
            ['name' => 'Margherita Pizza', 'price' => 15.50, 'category' => 'Pizza', 'description' => 'Classic Italian pizza with tomato sauce, fresh mozzarella, and sweet basil.', 'image_url' => 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Pepperoni Feast Pizza', 'price' => 17.99, 'category' => 'Pizza', 'description' => 'Loaded with double spicy pepperoni and premium mozzarella cheese.', 'image_url' => 'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'BBQ Chicken Pizza', 'price' => 16.99, 'category' => 'Pizza', 'description' => 'Tender chicken pieces, smoky BBQ sauce, red onion, cilantro, and mozzarella.', 'image_url' => 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=600&q=80'],
            // Salads
            ['name' => 'Caesar Salad', 'price' => 9.99, 'category' => 'Salads', 'description' => 'Fresh romaine lettuce, Caesar dressing, garlic croutons, parmesan flakes.', 'image_url' => 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Greek Feta Salad', 'price' => 10.50, 'category' => 'Salads', 'description' => 'Crispy cucumber, tomatoes, olives, red onion, premium Greek feta cheese.', 'image_url' => 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Quinoa Avocado Salad', 'price' => 11.99, 'category' => 'Salads', 'description' => 'Healthy quinoa mix with fresh avocado, cherry tomatoes, and citrus dressing.', 'image_url' => 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80'],
            // Japanese
            ['name' => 'Sushi Platter', 'price' => 24.99, 'category' => 'Japanese', 'description' => 'Assorted premium sushi rolls, nigiri, and fresh salmon sashimi.', 'image_url' => 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Tonkotsu Ramen', 'price' => 16.50, 'category' => 'Japanese', 'description' => 'Rich pork broth ramen, tender chashu pork slices, soft-boiled egg, and nori.', 'image_url' => 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Chicken Katsu Curry', 'price' => 15.99, 'category' => 'Japanese', 'description' => 'Crispy breaded chicken cutlet with rich Japanese curry sauce over rice.', 'image_url' => 'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&w=600&q=80'],
            // Pasta
            ['name' => 'Pasta Carbonara', 'price' => 14.50, 'category' => 'Pasta', 'description' => 'Creamy pasta with pan-fried pancetta, fresh egg yolk, and parmesan cheese.', 'image_url' => 'https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Seafood Spaghetti Marinara', 'price' => 18.99, 'category' => 'Pasta', 'description' => 'Spaghetti tossed with shrimp, mussels, and squid in rich tomato garlic sauce.', 'image_url' => 'https://images.unsplash.com/photo-1563379971899-660589a01ec3?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Creamy Mushroom Fettuccine', 'price' => 13.99, 'category' => 'Pasta', 'description' => 'Fettuccine pasta in rich creamy garlic sauce with sautéed mushrooms.', 'image_url' => 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?auto=format&fit=crop&w=600&q=80'],
            // Mexican
            ['name' => 'Spicy Beef Tacos', 'price' => 11.50, 'category' => 'Mexican', 'description' => 'Three crispy tacos filled with spiced ground beef, cheese, lettuce, and salsa.', 'image_url' => 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Grilled Chicken Burrito', 'price' => 12.50, 'category' => 'Mexican', 'description' => 'Large flour tortilla rolled with chicken, rice, black beans, guacamole, and cream.', 'image_url' => 'https://images.unsplash.com/photo-1626379616459-b2ce1d9decda?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Loaded Cheese Quesadilla', 'price' => 10.99, 'category' => 'Mexican', 'description' => 'Toasted tortilla filled with melted mozzarella, cheddar, bell peppers, and jalapeños.', 'image_url' => 'https://images.unsplash.com/photo-1615870216519-2f9fa575fa5c?auto=format&fit=crop&w=600&q=80'],
            // Desserts
            ['name' => 'Chocolate Fudge Cake', 'price' => 7.99, 'category' => 'Desserts', 'description' => 'Rich, moist chocolate cake with warm chocolate fudge layers.', 'image_url' => 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Strawberry Cheesecake', 'price' => 8.50, 'category' => 'Desserts', 'description' => 'New York style cheesecake topped with sweet strawberry compote.', 'image_url' => 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=600&q=80'],
            ['name' => 'Warm Waffles with Ice Cream', 'price' => 8.99, 'category' => 'Desserts', 'description' => 'Fresh baked waffles served with vanilla ice cream and maple syrup.', 'image_url' => 'https://images.unsplash.com/photo-1562376502-6f769499c886?auto=format&fit=crop&w=600&q=80'],
        ];

        foreach ($foods as $food) {
            FoodItem::create(array_merge($food, ['user_id' => $seller->id]));
        }
    }
}
