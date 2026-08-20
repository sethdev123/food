<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FoodItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FoodApiController extends Controller
{
    // Public: list all food items with optional search/category filters
    public function index(Request $request)
    {
        $query = FoodItem::with('seller:id,name');

        if ($request->filled('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        if ($request->filled('category') && $request->category !== 'All') {
            $query->where('category', $request->category);
        }

        $foods = $query->latest()->get()->map(fn ($f) => $this->foodResource($f));

        return response()->json($foods);
    }

    // Public: single food item
    public function show($id)
    {
        $food = FoodItem::with('seller:id,name')->findOrFail($id);
        return response()->json($this->foodResource($food));
    }

    // Seller: list ALL foods (full CRUD access)
    public function sellerIndex(Request $request)
    {
        $query = FoodItem::with('seller:id,name');

        if ($request->filled('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }
        if ($request->filled('category') && $request->category !== 'All') {
            $query->where('category', $request->category);
        }

        $foods = $query->latest()->get()->map(fn ($f) => $this->foodResource($f));
        return response()->json($foods);
    }

    // Seller: create food item
    public function sellerStore(Request $request)
    {
        $data = $request->validate([
            'name'        => 'required|string|max:255',
            'description' => 'nullable|string',
            'price'       => 'required|numeric|min:0',
            'image_url'   => 'nullable|url',
            'image'       => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'category'    => 'required|string|max:50',
        ]);

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('foods', 'public');
        }

        $data['user_id'] = $request->user()->id;
        $food = FoodItem::create($data);
        $food->load('seller:id,name');

        return response()->json($this->foodResource($food), 201);
    }

    // Seller: update ANY food item
    public function sellerUpdate(Request $request, $id)
    {
        $food = FoodItem::findOrFail($id);

        $data = $request->validate([
            'name'        => 'sometimes|string|max:255',
            'description' => 'sometimes|nullable|string',
            'price'       => 'sometimes|numeric|min:0',
            'image_url'   => 'sometimes|nullable|url',
            'image'       => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'category'    => 'sometimes|string|max:50',
        ]);

        if ($request->hasFile('image')) {
            if ($food->image) {
                Storage::disk('public')->delete($food->image);
            }
            $data['image'] = $request->file('image')->store('foods', 'public');
        }

        $food->update($data);
        $food->load('seller:id,name');

        return response()->json($this->foodResource($food));
    }

    // Seller: delete ANY food item
    public function sellerDestroy(Request $request, $id)
    {
        $food = FoodItem::findOrFail($id);
        $food->delete();
        return response()->json(['message' => 'Food item deleted.']);
    }

    private function foodResource(FoodItem $food): array
    {
        $image = $food->image
            ? url(Storage::url($food->image))
            : null;

        return [
            'id'          => $food->id,
            'name'        => $food->name,
            'description' => $food->description,
            'price'       => (float) $food->price,
            'image_url'   => $food->image_url,
            'image'       => $image,
            'category'    => $food->category,
            'seller_name' => $food->seller?->name ?? 'Unknown',
            'seller_id'   => $food->user_id,
            'created_at'  => $food->created_at?->toDateTimeString(),
        ];
    }
}
