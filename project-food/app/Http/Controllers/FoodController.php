<?php

namespace App\Http\Controllers;

use App\Models\FoodItem;
use Illuminate\Http\Request;

class FoodController extends Controller
{
    public function index()
    {
        $foodItems = FoodItem::with('seller')->get();
        return view('food.index', compact('foodItems'));
    }

    public function create()
    {
        return view('food.create');
    }

    public function store(Request $request)
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
            $data['image_url'] = null;
        }

        FoodItem::create(array_merge($data, ['user_id' => auth()->id()]));

        return redirect('/dashboard')->with('success', 'Food item added successfully!');
    }

    public function edit(FoodItem $food)
    {
        $role = auth()->user()->role;
        if ($role !== 'seller' && $role !== 'admin') abort(403);
        return view('food.edit', compact('food'));
    }

    public function update(Request $request, FoodItem $food)
    {
        $role = auth()->user()->role;
        if ($role !== 'seller' && $role !== 'admin') abort(403);

        $data = $request->validate([
            'name'        => 'required|string|max:255',
            'description' => 'nullable|string',
            'price'       => 'required|numeric|min:0',
            'image_url'   => 'nullable|url',
            'image'       => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'category'    => 'required|string|max:50',
        ]);

        if ($request->hasFile('image')) {
            if ($food->image) {
                \Storage::disk('public')->delete($food->image);
            }
            $data['image'] = $request->file('image')->store('foods', 'public');
            $data['image_url'] = null;
        } elseif ($request->filled('image_url')) {
            $data['image_url'] = $request->image_url;
            if ($food->image) {
                \Storage::disk('public')->delete($food->image);
                $data['image'] = null;
            }
        }

        $food->update($data);

        return redirect('/dashboard')->with('success', 'Food item updated!');
    }

    public function destroy(FoodItem $food)
    {
        $role = auth()->user()->role;
        if ($role !== 'seller' && $role !== 'admin') abort(403);

        if ($food->image) {
            \Storage::disk('public')->delete($food->image);
        }

        $food->delete();
        return redirect('/dashboard')->with('success', 'Food item deleted!');
    }
}
