@extends('layouts.app')

@section('content')
<div class="header" style="margin-bottom: 3rem;">
    <h1 style="font-size: 2.2rem; font-weight: 800; margin-bottom: 0.5rem; letter-spacing: -1px;">Delicious Food, Delivered</h1>
    <p style="color: var(--text-muted); font-size: 1.1rem; font-weight: 500;">Browse our selection and order your favorites.</p>
</div>

@if(session('success'))
    <div class="alert alert-success" style="background: rgba(0, 214, 143, 0.1); color: var(--accent-green); border: 1px solid rgba(0, 214, 143, 0.2); padding: 1.2rem; border-radius: 12px; margin-bottom: 2rem; font-weight: 600;">
        {{ session('success') }}
    </div>
@endif

<div class="food-grid">
    @foreach($foodItems as $item)
        <div class="food-item">
            <div style="position: relative;">
                <img src="{{ $item->image_url ?? 'https://via.placeholder.com/400x300?text=' . urlencode($item->name) }}" alt="{{ $item->name }}">
                <div style="position: absolute; top: 1rem; right: 1rem; background: var(--accent-pink); color: white; padding: 0.4rem 0.8rem; border-radius: 8px; font-weight: 800; font-size: 0.9rem;">
                    ${{ number_format($item->price, 2) }}
                </div>
            </div>
            <div class="food-info">
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 0.8rem;">
                    <h3 style="margin: 0;">{{ $item->name }}</h3>
                </div>
                <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.2rem; height: 3rem; overflow: hidden;">{{ $item->description }}</p>
                
                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border-color); padding-top: 1.2rem;">
                    <div style="font-size: 0.75rem; color: var(--text-muted);">
                        Sold by <span style="color: var(--accent-pink); font-weight: 700;">{{ $item->seller->name ?? 'Admin' }}</span>
                    </div>
                    @auth
                        <form action="/order" method="POST">
                            @csrf
                            <input type="hidden" name="food_item_id" value="{{ $item->id }}">
                            <input type="hidden" name="quantity" value="1">
                            <button type="submit" class="btn btn-pink" style="padding: 0.5rem 1rem;">Order</button>
                        </form>
                    @else
                        <a href="/login" class="btn btn-outline" style="border-color: var(--border-color); color: var(--text-muted);">Login</a>
                    @endauth
                </div>
            </div>
        </div>
    @endforeach
</div>
@endsection
