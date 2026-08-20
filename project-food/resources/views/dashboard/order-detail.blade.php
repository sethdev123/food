@extends('layouts.app')

@section('content')
<style>
  :root {
    --pink: #f97316;
    --pink-soft: rgba(249,115,22,0.1);
    --green: #00d68f;
    --green-soft: rgba(0,214,143,0.1);
    --blue: #4da6ff;
    --blue-soft: rgba(77,166,255,0.1);
    --yellow: #ffaa00;
    --yellow-soft: rgba(255,170,0,0.1);
    --card-glass: rgba(255,255,255,0.03);
    --card2: rgba(255,255,255,0.02);
    --border-glass: rgba(255,255,255,0.06);
    --text: #f0f0f5;
    --muted: #8888aa;
    --radius-lg: 16px;
    --radius-sm: 10px;
  }

  .detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.5rem;
    margin-bottom: 1.5rem;
  }

  .detail-card {
    background: var(--card-glass);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border-glass);
    padding: 1.5rem;
    transition: box-shadow 0.3s;
  }

  .detail-card:hover {
    box-shadow: 0 8px 32px rgba(0,0,0,0.3);
  }

  .detail-card.full {
    grid-column: 1 / -1;
  }

  .detail-card h3 {
    font-size: 1rem;
    font-weight: 700;
    margin-bottom: 1.2rem;
    padding-bottom: 0.8rem;
    border-bottom: 1px solid var(--border-glass);
  }

  .detail-row {
    display: flex;
    justify-content: space-between;
    padding: 0.6rem 0;
    border-bottom: 1px solid rgba(255,255,255,0.03);
    font-size: 0.875rem;
  }

  .detail-row:last-child {
    border-bottom: none;
  }

  .detail-label {
    color: var(--muted);
    font-weight: 500;
  }

  .detail-value {
    font-weight: 600;
  }

  .map-container {
    width: 100%;
    height: 350px;
    border-radius: var(--radius-sm);
    overflow: hidden;
    border: 1px solid var(--border-glass);
  }

  .items-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.875rem;
  }

  .items-table thead tr {
    border-bottom: 1px solid var(--border-glass);
  }

  .items-table th {
    padding: 0.7rem 0.5rem;
    color: var(--muted);
    font-weight: 600;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-align: left;
  }

  .items-table tbody tr {
    border-bottom: 1px solid rgba(255,255,255,0.03);
  }

  .items-table td {
    padding: 0.7rem 0.5rem;
  }

  .back-link {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    color: var(--muted);
    text-decoration: none;
    font-size: 0.875rem;
    font-weight: 600;
    margin-bottom: 1.5rem;
    transition: color 0.2s;
  }

  .back-link:hover {
    color: var(--pink);
  }

  .badge-status {
    display: inline-flex; align-items: center; gap: 0.3rem;
    padding: 0.25rem 0.75rem; border-radius: 20px; font-size: 0.75rem; font-weight: 700;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
  }
  .badge-pending   { background: var(--yellow-soft); color: var(--yellow); border: 1px solid rgba(255,170,0,0.15); }
  .badge-accepted  { background: var(--blue-soft);   color: var(--blue);  border: 1px solid rgba(77,166,255,0.15); }
  .badge-completed { background: var(--green-soft);  color: var(--green); border: 1px solid rgba(0,214,143,0.15); }
  .badge-cancelled { background: var(--pink-soft);   color: var(--pink);  border: 1px solid rgba(249,115,22,0.15); }
</style>

<a href="{{ url()->previous() }}" class="back-link">← Back</a>

<div class="detail-grid">
  {{-- Order Info --}}
  <div class="detail-card">
    <h3>📋 Order #{{ $order->id }}</h3>
    <div class="detail-row">
      <span class="detail-label">Status</span>
      <span>
        @if($order->status==='completed')
          <span class="badge-status badge-completed">● Completed</span>
        @elseif($order->status==='accepted')
          <span class="badge-status badge-accepted">● Accepted</span>
        @elseif($order->status==='cancelled')
          <span class="badge-status badge-cancelled">● Cancelled</span>
        @else
          <span class="badge-status badge-pending">● Pending</span>
        @endif
      </span>
    </div>
    <div class="detail-row">
      <span class="detail-label">Total Price</span>
      <span class="detail-value" style="color:var(--pink);">${{ number_format($order->total_price, 2) }}</span>
    </div>
    @if($order->discount_amount > 0)
    <div class="detail-row">
      <span class="detail-label">Discount</span>
      <span class="detail-value" style="color:var(--green);">-${{ number_format($order->discount_amount, 2) }}</span>
    </div>
    @endif
    @if($order->coupon_code)
    <div class="detail-row">
      <span class="detail-label">Coupon</span>
      <span class="detail-value">{{ $order->coupon_code }}</span>
    </div>
    @endif
    <div class="detail-row">
      <span class="detail-label">Payment</span>
      <span class="detail-value" style="text-transform:capitalize;">{{ $order->payment_method ?? 'Cash' }}</span>
    </div>
    <div class="detail-row">
      <span class="detail-label">Date</span>
      <span class="detail-value">{{ $order->created_at->format('M d, Y h:i A') }}</span>
    </div>
  </div>

  {{-- Customer Info --}}
  <div class="detail-card">
    <h3>👤 Customer</h3>
    <div class="detail-row">
      <span class="detail-label">Name</span>
      <span class="detail-value">{{ $order->user?->name ?? 'Unknown' }}</span>
    </div>
    <div class="detail-row">
      <span class="detail-label">Email</span>
      <span class="detail-value">{{ $order->user?->email ?? '—' }}</span>
    </div>
    <div class="detail-row">
      <span class="detail-label">Phone</span>
      <span class="detail-value">{{ $order->user?->phone_number ?? '—' }}</span>
    </div>
    <div class="detail-row">
      <span class="detail-label">Delivery Address</span>
      <span class="detail-value" style="text-align:right;max-width:200px;">{{ $order->delivery_address ?? '—' }}</span>
    </div>
  </div>

  {{-- Map --}}
  @if($order->latitude && $order->longitude)
  @php
    $lat = $order->latitude;
    $lng = $order->longitude;
    $bboxLeft = $lng - 0.01;
    $bboxBottom = $lat - 0.01;
    $bboxRight = $lng + 0.01;
    $bboxTop = $lat + 0.01;
  @endphp
  <div class="detail-card full">
    <h3>📍 Delivery Location</h3>
    <iframe
      class="map-container"
      style="border:0;"
      loading="lazy"
      src="https://www.openstreetmap.org/export/embed.html?bbox={{ $bboxLeft }},{{ $bboxBottom }},{{ $bboxRight }},{{ $bboxTop }}&layer=mapnik&marker={{ $lat }},{{ $lng }}">
    </iframe>
    <div style="margin-top:0.6rem;font-size:0.8rem;color:var(--muted);">
      <a href="https://www.google.com/maps?q={{ $lat }},{{ $lng }}" target="_blank" style="color:var(--pink);">Open in Google Maps →</a>
    </div>
  </div>
  @elseif($order->delivery_address)
  <div class="detail-card full">
    <h3>📍 Delivery Location</h3>
    <div style="padding:2rem;text-align:center;color:var(--muted);">
      <div style="font-size:2.5rem;margin-bottom:0.8rem;">📍</div>
      <p style="font-weight:600;margin-bottom:0.3rem;">{{ $order->delivery_address }}</p>
      <p style="font-size:0.8rem;margin-bottom:1rem;">No coordinates available for this order.</p>
      <a href="https://www.google.com/maps?q={{ urlencode($order->delivery_address) }}" target="_blank" class="btn-primary" style="text-decoration:none;">View on Google Maps →</a>
    </div>
  </div>
  @endif

  {{-- Items --}}
  <div class="detail-card full">
    <h3>🛒 Items ({{ $order->items->count() }})</h3>
    <table class="items-table">
      <thead>
        <tr>
          <th>Item</th>
          <th style="text-align:center;">Qty</th>
          <th style="text-align:right;">Price</th>
          <th style="text-align:right;">Subtotal</th>
        </tr>
      </thead>
      <tbody>
        @foreach($order->items as $item)
        <tr>
          <td style="font-weight:600;">{{ $item->foodItem?->name ?? 'Deleted item' }}</td>
          <td style="text-align:center;color:var(--muted);">{{ $item->quantity }}</td>
          <td style="text-align:right;color:var(--muted);">${{ number_format($item->price, 2) }}</td>
          <td style="text-align:right;font-weight:600;color:var(--pink);">${{ number_format($item->price * $item->quantity, 2) }}</td>
        </tr>
        @endforeach
      </tbody>
      <tfoot>
        <tr style="border-top:2px solid var(--border-glass);">
          <td colspan="3" style="text-align:right;font-weight:700;padding:0.8rem 0.5rem;">Total</td>
          <td style="text-align:right;font-weight:800;color:var(--pink);padding:0.8rem 0.5rem;font-size:1.1rem;">${{ number_format($order->total_price, 2) }}</td>
        </tr>
      </tfoot>
    </table>
  </div>
</div>

@endsection
