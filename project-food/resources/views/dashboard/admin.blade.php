@extends('layouts.app')

@section('content')
<style>
    .page-title h1 { font-size: 1.8rem; font-weight: 800; margin-bottom: 0.5rem; letter-spacing: -0.5px; }
    .page-title p { color: var(--text-muted); font-size: 0.9rem; }
    .trend-up { color: var(--accent-green); font-weight: 700; }
    .trend-blue { color: var(--accent-blue); font-weight: 700; }
    .trend-yellow { color: var(--accent-yellow); font-weight: 700; }
    .best-item { display: flex; align-items: center; gap: 1rem; }
    .best-item-placeholder {
        width: 40px; height: 40px; border-radius: 10px; flex-shrink: 0;
        background: rgba(255, 255, 255, 0.04);
        border: 1px solid var(--glass-border);
    }
    .best-item-name { font-weight: 600; }
    .best-item-cat { font-size: 0.75rem; color: var(--text-muted); }
    .promo-card {
        display: flex; justify-content: space-between; align-items: center;
        padding: 1rem; border-radius: 12px; margin-bottom: 1rem;
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
    }
    .promo-card.pink {
        background: rgba(249, 115, 22, 0.05);
        border: 1px solid rgba(249, 115, 22, 0.08);
    }
    .promo-card.blue {
        background: rgba(77, 166, 255, 0.05);
        border: 1px solid rgba(77, 166, 255, 0.08);
    }
    .promo-value { font-weight: 800; }
    .promo-value.pink { color: var(--accent-pink); }
    .promo-value.blue { color: var(--accent-blue); }
    .chart-legend { display: flex; gap: 1.2rem; font-size: 0.8rem; font-weight: 600; }
    .legend-revenue { color: var(--accent-pink); }
    .legend-expenses { color: var(--accent-blue); }
    .btn-ghost {
        width: 100%; margin-top: 1.5rem;
        background: rgba(249, 115, 22, 0.08);
        color: var(--accent-pink);
        padding: 0.6rem 1.2rem; border-radius: 10px; font-weight: 600;
        cursor: pointer; border: 1px solid rgba(249, 115, 22, 0.12);
        transition: all 0.25s; font-size: 0.85rem;
        font-family: 'Inter', sans-serif;
    }
    .btn-ghost:hover { background: rgba(249, 115, 22, 0.15); }
    .btn-complete {
        padding: 0.4rem 0.8rem; font-size: 0.7rem;
        background: linear-gradient(135deg, var(--accent-pink), #fb923c);
        color: white; border: none; border-radius: 8px; font-weight: 600;
        cursor: pointer; transition: all 0.2s;
        box-shadow: 0 4px 12px rgba(249, 115, 22, 0.2);
    }
    .btn-complete:hover { transform: translateY(-1px); box-shadow: 0 6px 18px rgba(249, 115, 22, 0.3); }
    .orders-section { margin-top: 1.5rem; }
</style>

<div class="page-title" style="margin-bottom:2rem;">
    <h1>Food Dashboard</h1>
    <p>Real-time tracking of sales, orders, and user engagement.</p>
</div>

<div class="grid">
    <div class="card">
        <div class="card-header">
            <span>Sales Overview</span>
            <div class="icon-box bg-pink" style="width:32px;height:32px;font-size:0.8rem;">$</div>
        </div>
        <div class="card-value">${{ number_format($totalSales, 2) }}</div>
        <div class="card-sub">
            <span class="trend-up">↑ 12.5%</span> vs last month
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <span>User Engagement</span>
            <div class="icon-box bg-blue" style="width:32px;height:32px;font-size:0.8rem;">👤</div>
        </div>
        <div class="card-value">8,360</div>
        <div class="card-sub">
            <span class="trend-blue">↑ 540</span> new users today
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <span>Order Status</span>
            <div class="icon-box bg-green" style="width:32px;height:32px;font-size:0.8rem;">🛒</div>
        </div>
        <div class="card-value">{{ $orders->count() }}</div>
        <div class="card-sub">
            <span style="color:var(--accent-green);font-weight:700;">{{ $orders->where('status', 'completed')->count() }}</span> completed,
            <span class="trend-yellow">{{ $pendingOrders }}</span> pending
        </div>
    </div>
</div>

<div class="grid" style="margin-top:1.5rem;grid-template-columns:2fr 1fr;">
    <div class="card">
        <h3 class="card-title">Best Selling Items</h3>
        <div style="display:flex;flex-direction:column;">
            <div class="list-item">
                <div class="best-item">
                    <div class="best-item-placeholder"></div>
                    <div>
                        <div class="best-item-name">Pepperoni Pizza</div>
                        <div class="best-item-cat">Main Course</div>
                    </div>
                </div>
                <span class="badge badge-green">248 sold</span>
            </div>
            <div class="list-item">
                <div class="best-item">
                    <div class="best-item-placeholder"></div>
                    <div>
                        <div class="best-item-name">Cheese Burger</div>
                        <div class="best-item-cat">Fast Food</div>
                    </div>
                </div>
                <span class="badge badge-green">192 sold</span>
            </div>
            <div class="list-item">
                <div class="best-item">
                    <div class="best-item-placeholder"></div>
                    <div>
                        <div class="best-item-name">Garden Salad</div>
                        <div class="best-item-cat">Healthy</div>
                    </div>
                </div>
                <span class="badge badge-green">156 sold</span>
            </div>
        </div>
        <button class="btn-ghost">View All Items</button>
    </div>

    <div class="card">
        <h3 class="card-title">Active Promotions</h3>
        <div class="promo-card pink">
            <div>
                <div style="font-weight:600;">Happy Hour 2-for-1</div>
                <div style="font-size:0.75rem;color:var(--text-muted);">Ends in 2 days</div>
            </div>
            <div class="promo-value pink">50%</div>
        </div>
        <div class="promo-card blue">
            <div>
                <div style="font-weight:600;">Free Delivery</div>
                <div style="font-size:0.75rem;color:var(--text-muted);">Orders above $50</div>
            </div>
            <div class="promo-value blue">FREE</div>
        </div>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
        <h3 class="card-title" style="margin-bottom:0;">Revenue Trends</h3>
        <div class="chart-legend">
            <span class="legend-revenue">● Revenue</span>
            <span class="legend-expenses">● Expenses</span>
        </div>
    </div>
    <div class="chart-placeholder">
        <svg viewBox="0 0 1000 200" style="width:100%;height:100%;">
            <path d="M0,150 Q100,120 200,140 T400,100 T600,80 T800,120 T1000,60" fill="none" stroke="var(--accent-pink)" stroke-width="4" />
            <path d="M0,180 Q150,160 300,170 T600,140 T1000,150" fill="none" stroke="var(--accent-blue)" stroke-width="3" opacity="0.5" />
        </svg>
    </div>
</div>

<div class="card orders-section">
    <h3 class="card-title">Recent Orders</h3>
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Status</th>
                <th>Total</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @foreach($orders->take(5) as $order)
            <tr>
                <td style="font-weight:700;color:var(--accent-pink);">#{{ $order->id }}</td>
                <td>{{ $order->user->name }}</td>
                <td>
                    <span class="status-badge status-{{ $order->status }}">
                        ● {{ ucfirst($order->status) }}
                    </span>
                </td>
                <td style="font-weight:700;">${{ number_format($order->total_price, 2) }}</td>
                <td>
                    @if($order->status === 'pending' || $order->status === 'accepted')
                    <form action="/orders/{{ $order->id }}/status" method="POST" style="display:inline;">
                        @csrf
                        @method('PATCH')
                        <input type="hidden" name="status" value="completed">
                        <button type="submit" class="btn-complete">Complete</button>
                    </form>
                    @endif
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.status-pending').forEach(function(badge) {
        var row = badge.closest('tr');
        if (!row) return;
        var orderId = row.querySelector('td:first-child')?.textContent?.trim()?.replace('#', '');
        if (!orderId) return;
        var priceText = row.querySelectorAll('td')[3]?.textContent?.trim()?.replace('$', '')?.replace(',', '');
        var price = parseFloat(priceText) || 0;
        var delay = 3000 + Math.random() * 1000;
        setTimeout(function() {
            fetch('/orders/' + orderId + '/accept', { method: 'PATCH', headers: { 'X-CSRF-TOKEN': '{{ csrf_token() }}', 'Accept': 'application/json' } })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success) {
                        badge.className = 'status-badge status-accepted';
                        badge.textContent = '● Accepted';
                        var actionCell = row.querySelector('td:last-child');
                        if (actionCell) actionCell.innerHTML = '';
                        var totalEl = document.querySelector('.card-value');
                        if (totalEl && price) {
                            var current = parseFloat(totalEl.textContent.trim().replace('$', '').replace(',', '')) || 0;
                            totalEl.textContent = '$' + (current + price).toFixed(2);
                        }
                    }
                });
        }, delay);
    });
});
</script>
@endpush
