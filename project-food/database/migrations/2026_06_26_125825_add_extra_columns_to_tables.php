<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add category to food_items
        Schema::table('food_items', function (Blueprint $table) {
            $table->string('category')->default('Other')->after('image_url');
        });

        // Add extra fields to orders
        Schema::table('orders', function (Blueprint $table) {
            $table->string('delivery_address')->nullable()->after('status');
            $table->string('payment_method')->default('cash')->after('delivery_address');
            $table->string('coupon_code')->nullable()->after('payment_method');
            $table->decimal('discount_amount', 10, 2)->default(0)->after('coupon_code');
        });

        // Add phone_number and address to users
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone_number')->nullable()->after('email');
            $table->string('address')->nullable()->after('phone_number');
        });
    }

    public function down(): void
    {
        Schema::table('food_items', function (Blueprint $table) {
            $table->dropColumn('category');
        });
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['delivery_address', 'payment_method', 'coupon_code', 'discount_amount']);
        });
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['phone_number', 'address']);
        });
    }
};
