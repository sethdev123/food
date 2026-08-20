@extends('layouts.app')

@section('content')
<style>
    .user-header { margin-bottom: 2rem; }
    .user-header h1 { font-size: 1.8rem; font-weight: 800; margin-bottom: 0.5rem; letter-spacing: -0.5px; }
    .user-header p { color: var(--text-muted); font-size: 0.9rem; }
    .alert-success {
        background: rgba(0, 214, 143, 0.08);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border: 1px solid rgba(0, 214, 143, 0.15);
        color: var(--accent-green);
        padding: 1rem 1.2rem;
        border-radius: 12px;
        margin-bottom: 2rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 0.6rem;
    }
    .user-card {
        background: rgba(255, 255, 255, 0.03);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.06);
        border-radius: var(--radius);
        padding: 2rem;
        overflow: hidden;
        transition: box-shadow 0.3s;
    }
    .user-card:hover {
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    }
    .empty-state {
        text-align: center;
        padding: 4rem 2rem;
    }
    .empty-state .emoji { font-size: 4rem; display: block; margin-bottom: 1rem; }
    .empty-state h3 { margin-bottom: 0.5rem; font-size: 1.3rem; }
    .empty-state p { color: var(--text-muted); margin-bottom: 2rem; }
    .order-id { font-weight: 700; color: var(--accent-pink); }
    .order-total { font-weight: 700; }
    .order-date { color: var(--text-muted); font-size: 0.85rem; }
    .item-name { font-weight: 600; }
    .item-qty { font-size: 0.75rem; color: var(--text-muted); }
</style>

<div class="user-header">
    <h1>Your Orders</h1>
    <p>Track your food deliveries and history.</p>
</div>

@if(session('success'))
    <div class="alert-success">✅ {{ session('success') }}</div>
@endif

<div class="user-card">
    @if($orders->isEmpty())
        <div class="empty-state">
            <span class="emoji">🍔</span>
            <h3>No orders yet</h3>
            <p>Hungry? Browse our menu and place your first order.</p>
            <a href="/" class="btn btn-pink">Browse Menu</a>
        </div>
    @else
        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Items</th>
                    <th>Total Price</th>
                    <th>Status</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>
                @foreach($orders as $order)
                    <tr>
                        <td class="order-id">#{{ $order->id }}</td>
                        <td>
                            @foreach($order->items as $item)
                                <div class="item-name">{{ $item->foodItem->name }}</div>
                                <div class="item-qty">Qty: {{ $item->quantity }}</div>
                            @endforeach
                        </td>
                        <td class="order-total">${{ number_format($order->total_price, 2) }}</td>
                        <td>
                            <span class="status-badge status-{{ $order->status }}">
                                ● {{ ucfirst($order->status) }}
                            </span>
                        </td>
                        <td class="order-date">{{ $order->created_at->format('M d, Y H:i') }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif
</div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.status-pending').forEach(function(badge) {
        var row = badge.closest('tr');
        if (!row) return;
        var cells = row.querySelectorAll('td');
        if (cells.length < 2) return;
        var orderId = cells[0]?.textContent?.trim()?.replace('#', '');
        if (!orderId) return;
        var delay = 3000 + Math.random() * 1000;
        setTimeout(function() {
            fetch('/orders/' + orderId + '/accept', { method: 'PATCH', headers: { 'X-CSRF-TOKEN': '{{ csrf_token() }}', 'Accept': 'application/json' } })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success) {
                        badge.className = 'status-badge status-accepted';
                        badge.textContent = '● Accepted';
                    }
                });
        }, delay);
    });
});
</script>
@endpush
