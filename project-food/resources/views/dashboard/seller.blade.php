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

  * { box-sizing: border-box; margin: 0; padding: 0; }

  /* ── Page header ── */
  .page-header {
    display: flex; justify-content: space-between; align-items: center;
    margin-bottom: 2rem;
  }
  .page-header h1 { font-size: 1.75rem; font-weight: 800; letter-spacing: -0.5px; }
  .page-header p  { color: var(--muted); font-size: 0.9rem; margin-top: 0.2rem; }

  /* ── Stat cards ── */
  .stats-grid {
    display: grid; grid-template-columns: repeat(4,1fr); gap: 1.2rem;
    margin-bottom: 2rem;
  }
  .stat-card {
    background: var(--card-glass);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-radius: var(--radius-lg);
    padding: 1.4rem 1.6rem;
    border: 1px solid var(--border-glass);
    position: relative; overflow: hidden;
    transition: transform 0.3s, box-shadow 0.3s;
  }
  .stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 16px 48px rgba(0,0,0,0.4);
    border-color: rgba(255,255,255,0.1);
  }
  .stat-card::before {
    content: '';
    position: absolute;
    top: -40px; right: -40px;
    width: 120px; height: 120px;
    border-radius: 50%;
    opacity: 0.08;
  }
  .stat-card.pink::before  { background: var(--pink); }
  .stat-card.green::before { background: var(--green); }
  .stat-card.blue::before  { background: var(--blue); }
  .stat-card.yellow::before{ background: var(--yellow); }
  .stat-icon {
    width: 44px; height: 44px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.3rem; margin-bottom: 1rem;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
  }
  .stat-icon.pink   { background: var(--pink-soft); box-shadow: 0 0 20px rgba(249,115,22,0.08); }
  .stat-icon.green  { background: var(--green-soft); box-shadow: 0 0 20px rgba(0,214,143,0.08); }
  .stat-icon.blue   { background: var(--blue-soft); box-shadow: 0 0 20px rgba(77,166,255,0.08); }
  .stat-icon.yellow { background: var(--yellow-soft); box-shadow: 0 0 20px rgba(255,170,0,0.08); }
  .stat-value { font-size: 1.8rem; font-weight: 800; margin-bottom: 0.2rem; letter-spacing: -1px; }
  .stat-label { color: var(--muted); font-size: 0.78rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.8px; }

  /* ── Section ── */
  .section {
    background: var(--card-glass);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border-glass);
    margin-bottom: 1.5rem;
    overflow: hidden;
    transition: box-shadow 0.3s;
  }
  .section:hover {
    box-shadow: 0 8px 32px rgba(0,0,0,0.3);
  }
  .section-head {
    display: flex; justify-content: space-between; align-items: center;
    padding: 1.2rem 1.6rem;
    border-bottom: 1px solid var(--border-glass);
  }
  .section-title { font-size: 1rem; font-weight: 700; }
  .section-sub   { color: var(--muted); font-size: 0.8rem; }

  /* ── Buttons ── */
  .btn-primary {
    display: inline-flex; align-items: center; gap: 0.5rem;
    background: linear-gradient(135deg, var(--pink), #fb923c);
    color: #fff; border: none; border-radius: var(--radius-sm);
    padding: 0.6rem 1.2rem; font-weight: 600; font-size: 0.85rem;
    cursor: pointer; transition: all 0.25s; text-decoration: none;
    font-family: 'Inter', sans-serif;
    box-shadow: 0 4px 15px rgba(249,115,22,0.25);
  }
  .btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(249,115,22,0.35);
  }

  .btn-sm {
    display: inline-flex; align-items: center; gap: 0.3rem;
    padding: 0.35rem 0.75rem; border-radius: 8px; font-size: 0.78rem;
    font-weight: 600; cursor: pointer; border: none; transition: all 0.2s;
    text-decoration: none; font-family: 'Inter', sans-serif;
  }
  .btn-edit   {
    background: var(--blue-soft); color: var(--blue);
    border: 1px solid rgba(77,166,255,0.15);
  }
  .btn-edit:hover  { background: rgba(77,166,255,0.2); }
  .btn-delete {
    background: var(--pink-soft); color: var(--pink);
    border: 1px solid rgba(249,115,22,0.15);
  }
  .btn-delete:hover{ background: rgba(249,115,22,0.2); }

  /* ── Food grid ── */
  .food-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 1.2rem; padding: 1.4rem;
  }
  .food-card {
    background: var(--card2);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border-radius: 14px;
    border: 1px solid var(--border-glass);
    overflow: hidden;
    transition: transform 0.3s, box-shadow 0.3s;
    display: flex; flex-direction: column;
  }
  .food-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 20px 48px rgba(0,0,0,0.4);
    border-color: rgba(255,255,255,0.1);
  }
  .food-card-img {
    width: 100%; height: 150px; object-fit: cover;
  }
  .food-card-img-placeholder {
    width: 100%; height: 150px;
    background: linear-gradient(135deg, rgba(255,255,255,0.02), rgba(255,255,255,0.04));
    display: flex; align-items: center; justify-content: center; font-size: 3rem;
  }
  .food-card-body { padding: 1rem; flex: 1; display: flex; flex-direction: column; gap: 0.4rem; }
  .food-card-name { font-weight: 700; font-size: 0.95rem; line-height: 1.3; }
  .food-card-cat  {
    display: inline-block;
    background: var(--pink-soft);
    border: 1px solid rgba(249,115,22,0.15);
    color: var(--pink);
    padding: 0.2rem 0.6rem; border-radius: 6px;
    font-size: 0.72rem; font-weight: 700;
  }
  .food-card-price { color: var(--pink); font-weight: 800; font-size: 1.1rem; margin-top: auto; }
  .food-card-desc { color: var(--muted); font-size: 0.78rem; line-height: 1.4; }
  .food-card-actions { display: flex; gap: 0.5rem; padding: 0 1rem 1rem; }
  .food-card-actions .btn-sm { flex: 1; justify-content: center; }

  /* ── Orders table ── */
  table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
  thead tr { border-bottom: 1px solid var(--border-glass); }
  th { padding: 0.8rem 1rem; color: var(--muted); font-weight: 600; font-size: 0.78rem;
       text-transform: uppercase; letter-spacing: 0.5px; text-align: left; }
  tbody tr { border-bottom: 1px solid var(--border-glass); transition: background 0.15s; }
  tbody tr:last-child { border-bottom: none; }
  tbody tr:hover { background: rgba(255,255,255,0.03); }
  td { padding: 0.85rem 1rem; }
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

  /* ── Modal ── */
  .modal-overlay {
    display: none; position: fixed; inset: 0;
    background: rgba(0,0,0,0.6);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    z-index: 1000;
    align-items: center; justify-content: center;
  }
  .modal-overlay.open { display: flex; }
  .modal {
    background: rgba(13,13,36,0.95);
    backdrop-filter: blur(30px);
    -webkit-backdrop-filter: blur(30px);
    border: 1px solid var(--border-glass);
    border-radius: 20px;
    width: 100%; max-width: 560px; max-height: 90vh; overflow-y: auto;
    animation: slideUp 0.3s ease;
    box-shadow: 0 25px 60px rgba(0,0,0,0.5);
  }
  @keyframes slideUp { from { transform: translateY(40px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
  .modal-head {
    display: flex; justify-content: space-between; align-items: center;
    padding: 1.4rem 1.6rem; border-bottom: 1px solid var(--border-glass);
  }
  .modal-head h3 { font-size: 1.1rem; font-weight: 700; }
  .modal-close {
    width: 32px; height: 32px; border-radius: 8px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--border-glass);
    color: var(--text); font-size: 1.2rem; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: all 0.15s;
  }
  .modal-close:hover { background: var(--pink-soft); color: var(--pink); border-color: rgba(249,115,22,0.2); }
  .modal-body { padding: 1.6rem; display: flex; flex-direction: column; gap: 1.1rem; }
  .modal-footer { padding: 1rem 1.6rem; border-top: 1px solid var(--border-glass); display: flex; gap: 0.8rem; }

  /* ── Form elements ── */
  .form-group label {
    display: block; font-size: 0.8rem; font-weight: 600;
    color: var(--muted); margin-bottom: 0.5rem;
    text-transform: uppercase; letter-spacing: 0.8px;
  }
  .form-group input, .form-group select, .form-group textarea {
    width: 100%; padding: 0.75rem 1rem; border-radius: var(--radius-sm);
    border: 1px solid var(--border-glass);
    background: rgba(255,255,255,0.03);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    color: var(--text); font-size: 0.9rem; outline: none;
    transition: all 0.25s; font-family: 'Inter', sans-serif;
  }
  .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
    border-color: var(--pink);
    box-shadow: 0 0 0 3px rgba(249,115,22,0.12);
  }
  .form-group textarea { resize: vertical; min-height: 80px; }
  .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }

  .img-preview {
    width: 100%; height: 140px; border-radius: 10px; object-fit: cover;
    border: 1px solid var(--border-glass); margin-top: 0.5rem; display: none;
  }

  .btn-full { width: 100%; justify-content: center; padding: 0.8rem; font-size: 0.95rem; }
  .btn-cancel {
    flex: 1; padding: 0.75rem; border-radius: var(--radius-sm);
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--border-glass);
    color: var(--text); font-weight: 600; cursor: pointer;
    transition: all 0.15s; font-family: 'Inter', sans-serif;
  }
  .btn-cancel:hover { background: rgba(255,255,255,0.08); }
  .btn-submit { flex: 1; }

  /* ── Alert ── */
  .alert-success {
    background: var(--green-soft);
    border: 1px solid rgba(0,214,143,0.2);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    color: var(--green);
    padding: 0.9rem 1.2rem; border-radius: 12px; font-weight: 600; margin-bottom: 1.5rem;
    display: flex; align-items: center; gap: 0.6rem;
  }
  .alert-error {
    background: var(--pink-soft);
    border: 1px solid rgba(249,115,22,0.2);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    color: var(--pink);
    padding: 0.9rem 1.2rem; border-radius: 12px; font-weight: 600; margin-bottom: 1.5rem;
  }

  /* ── Empty state ── */
  .empty-state {
    padding: 3rem; text-align: center; color: var(--muted);
  }
  .empty-state .emoji { font-size: 3.5rem; display: block; margin-bottom: 1rem; }
  .empty-state p { font-size: 1rem; margin-bottom: 1.2rem; }

  /* ── Search bar ── */
  .search-bar {
    display: flex; gap: 0.8rem; align-items: center;
    padding: 1rem 1.4rem; border-bottom: 1px solid var(--border-glass);
  }
  .search-input {
    flex: 1; padding: 0.6rem 1rem; border-radius: var(--radius-sm);
    border: 1px solid var(--border-glass);
    background: rgba(255,255,255,0.03);
    color: var(--text); font-size: 0.875rem; outline: none;
    font-family: 'Inter', sans-serif;
  }
  .search-input:focus { border-color: var(--pink); }

  @media (max-width: 900px) {
    .stats-grid { grid-template-columns: repeat(2,1fr); }
    .form-row   { grid-template-columns: 1fr; }
  }
</style>

{{-- ─── ALERTS ─── --}}
@if(session('success'))
<div class="alert-success">✅ {{ session('success') }}</div>
@endif
@if($errors->any())
<div class="alert-error">
  @foreach($errors->all() as $err)<div>• {{ $err }}</div>@endforeach
</div>
@endif

{{-- ─── HEADER ─── --}}
<div class="page-header">
  <div>
    <h1>🍽️ Seller Dashboard</h1>
    <p>Welcome back, <strong>{{ Auth::user()->name }}</strong> — manage your menu and track orders</p>
  </div>
  <button class="btn-primary" onclick="openModal('add')">
    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>
    Add Food Item
  </button>
</div>

{{-- ─── STATS ─── --}}
<div class="stats-grid">
  <div class="stat-card pink">
    <div class="stat-icon pink">💰</div>
    <div class="stat-value">${{ number_format($totalRevenue,2) }}</div>
    <div class="stat-label">Total Revenue</div>
  </div>
  <div class="stat-card green">
    <div class="stat-icon green">📦</div>
    <div class="stat-value">{{ $totalOrders }}</div>
    <div class="stat-label">Total Orders</div>
  </div>
  <div class="stat-card yellow">
    <div class="stat-icon yellow">⏳</div>
    <div class="stat-value">{{ $pendingOrders }}</div>
    <div class="stat-label">Pending</div>
  </div>
  <div class="stat-card blue">
    <div class="stat-icon blue">🍕</div>
    <div class="stat-value">{{ $totalFoods }}</div>
    <div class="stat-label">My Foods</div>
  </div>
</div>

{{-- ─── MY FOODS ─── --}}
<div class="section">
  <div class="section-head">
    <div>
      <div class="section-title">All Food Items</div>
      <div class="section-sub">{{ $myFoods->count() }} total items — you can edit or delete any item</div>
    </div>
    <button class="btn-primary" onclick="openModal('add')" style="padding:0.5rem 1rem;font-size:0.8rem;">
      + Add Item
    </button>
  </div>

  @if($myFoods->isEmpty())
  <div class="empty-state">
    <span class="emoji">🍽️</span>
    <p>You haven't added any food items yet.</p>
    <button class="btn-primary btn-full" style="max-width:220px;margin:0 auto;" onclick="openModal('add')">+ Add your first item</button>
  </div>
  @else
  <div class="food-grid">
    @foreach($myFoods as $food)
    <div class="food-card">
      @php $imgSrc = $food->image ? \Storage::url($food->image) : $food->image_url; @endphp
      @if($imgSrc)
        <img src="{{ $imgSrc }}" alt="{{ $food->name }}" class="food-card-img" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div class="food-card-img-placeholder" style="display:none;">🍽️</div>
      @else
        <div class="food-card-img-placeholder">🍽️</div>
      @endif
      <div class="food-card-body">
        <div style="display:flex;justify-content:space-between;align-items:center;gap:0.4rem;">
          <span class="food-card-cat">{{ $food->category }}</span>
          <span style="font-size:0.7rem;color:var(--muted);white-space:nowrap;">by {{ $food->seller?->name ?? 'Unknown' }}</span>
        </div>
        <div class="food-card-name">{{ $food->name }}</div>
        @if($food->description)
          <div class="food-card-desc">{{ Str::limit($food->description, 65) }}</div>
        @endif
        <div class="food-card-price">${{ number_format($food->price,2) }}</div>
      </div>
      <div class="food-card-actions">
        <button class="btn-sm btn-edit" onclick='openEditModal({{ json_encode($food) }})'>✏️ Edit</button>
        <form method="POST" action="/food/{{ $food->id }}" style="flex:1;display:flex;" onsubmit="return confirmDelete(event,'{{ addslashes($food->name) }}')">
          @csrf @method('DELETE')
          <button type="submit" class="btn-sm btn-delete" style="flex:1;justify-content:center;">🗑️ Delete</button>
        </form>
      </div>
    </div>
    @endforeach
  </div>
  @endif
</div>

{{-- ─── ORDERS ─── --}}
<div class="section">
  <div class="section-head">
    <div>
      <div class="section-title">Recent Orders</div>
      <div class="section-sub">Orders containing your food items</div>
    </div>
  </div>

  @if($orders->isEmpty())
  <div class="empty-state">
    <span class="emoji">📭</span>
    <p>No orders yet. Share your menu to get started!</p>
  </div>
  @else
  <div style="overflow-x:auto;">
    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Customer</th>
          <th>Items Ordered</th>
          <th>Total</th>
          <th>Payment</th>
          <th>Status</th>
          <th>Date</th>
          <th style="text-align:center;">Action</th>
        </tr>
      </thead>
      <tbody>
        @foreach($orders as $order)
        @php $myItems = $order->items->filter(fn($i)=>$i->foodItem && $i->foodItem->user_id===Auth::id()); @endphp
        <tr>
          <td style="color:var(--muted);font-weight:600;">#{{ $order->id }}</td>
          <td>
            <div style="font-weight:600;font-size:0.875rem;">{{ $order->user?->name ?? 'Guest' }}</div>
            <div style="color:var(--muted);font-size:0.75rem;">{{ $order->user?->email ?? '' }}</div>
          </td>
          <td style="color:var(--muted);font-size:0.8rem;max-width:220px;">
            {{ $myItems->map(fn($i)=>$i->foodItem->name.' ×'.$i->quantity)->join(', ') }}
          </td>
          <td style="font-weight:700;color:var(--pink);">${{ number_format($order->total_price,2) }}</td>
          <td style="color:var(--muted);font-size:0.8rem;text-transform:capitalize;">{{ $order->payment_method ?? 'cash' }}</td>
          <td>
            @if($order->status==='completed')
              <span class="badge-status badge-completed">● Completed</span>
            @elseif($order->status==='accepted')
              <span class="badge-status badge-accepted">● Accepted</span>
            @elseif($order->status==='cancelled')
              <span class="badge-status badge-cancelled">● Cancelled</span>
            @else
              <span class="badge-status badge-pending">● Pending</span>
            @endif
          </td>
          <td style="color:var(--muted);font-size:0.8rem;">{{ $order->created_at->format('M d, Y') }}</td>
          <td style="text-align:center;">
            <a href="{{ route('orders.show', $order) }}" class="btn-sm btn-edit" style="text-decoration:none;">👁️ View</a>
          </td>
        </tr>
        @endforeach
      </tbody>
    </table>
  </div>
  @endif
</div>

<div style="height:80px;"></div>

{{-- ═══ ADD MODAL ═══ --}}
<div class="modal-overlay" id="addModal" onclick="closeOnOverlay(event,'addModal')">
  <div class="modal">
    <div class="modal-head">
      <h3>➕ Add New Food Item</h3>
      <button class="modal-close" onclick="closeModal('addModal')">✕</button>
    </div>
    <form method="POST" action="/food" enctype="multipart/form-data">
      @csrf
      <div class="modal-body">
        <div class="form-group">
          <label>Food Name *</label>
          <input type="text" name="name" required placeholder="e.g. Pepperoni Pizza" value="{{ old('name') }}">
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>Category *</label>
            <select name="category" style="background:#0a192f;color:#fff;" required>
              <option value="">Select…</option>
              @foreach(['Pizza','Burger','Sushi','Drinks','Desserts','Healthy','Asian','Chicken','Seafood','Vegetarian','Other'] as $cat)
              <option value="{{ $cat }}" {{ old('category')===$cat?'selected':'' }}>{{ $cat }}</option>
              @endforeach
            </select>
          </div>
          <div class="form-group">
            <label>Price ($) *</label>
            <input type="number" name="price" step="0.01" min="0" required placeholder="0.00" value="{{ old('price') }}">
          </div>
        </div>
        <div class="form-group">
          <label>Image (URL or Upload)</label>
          <div style="display:flex;gap:0.5rem;align-items:center;margin-bottom:0.5rem;">
            <input type="url" name="image_url" id="add_image_url" placeholder="https://images.unsplash.com/..." oninput="previewImg(this,'add_preview')" value="{{ old('image_url') }}" style="flex:1;">
            <span style="color:var(--muted);font-size:0.8rem;font-weight:600;">OR</span>
            <label class="btn-primary" style="padding:0.55rem 1rem;font-size:0.8rem;cursor:pointer;white-space:nowrap;margin:0;">
              📁 Browse
              <input type="file" name="image" accept="image/jpeg,image/png,image/jpg,image/gif,image/webp" style="display:none;" onchange="previewFile(this,'add_preview')">
            </label>
          </div>
          <img id="add_preview" class="img-preview" alt="preview">
        </div>
        <div class="form-group">
          <label>Description</label>
          <textarea name="description" placeholder="Describe your food item...">{{ old('description') }}</textarea>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Cancel</button>
        <button type="submit" class="btn-primary btn-submit">✅ Add Food Item</button>
      </div>
    </form>
  </div>
</div>

{{-- ═══ EDIT MODAL ═══ --}}
<div class="modal-overlay" id="editModal" onclick="closeOnOverlay(event,'editModal')">
  <div class="modal">
    <div class="modal-head">
      <h3>✏️ Edit Food Item</h3>
      <button class="modal-close" onclick="closeModal('editModal')">✕</button>
    </div>
    <form method="POST" id="editForm" action="" enctype="multipart/form-data">
      @csrf @method('PATCH')
      <div class="modal-body">
        <div class="form-group">
          <label>Food Name *</label>
          <input type="text" name="name" id="edit_name" required>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>Category *</label>
            <select name="category" id="edit_category" style="background:#0a192f;color:#fff;" required>
              @foreach(['Pizza','Burger','Sushi','Drinks','Desserts','Healthy','Asian','Chicken','Seafood','Vegetarian','Other'] as $cat)
              <option value="{{ $cat }}">{{ $cat }}</option>
              @endforeach
            </select>
          </div>
          <div class="form-group">
            <label>Price ($) *</label>
            <input type="number" name="price" id="edit_price" step="0.01" min="0" required>
          </div>
        </div>
        <div class="form-group">
          <label>Image (URL or Upload)</label>
          <div style="display:flex;gap:0.5rem;align-items:center;margin-bottom:0.5rem;">
            <input type="url" name="image_url" id="edit_image_url" oninput="previewImg(this,'edit_preview')" placeholder="https://..." style="flex:1;">
            <span style="color:var(--muted);font-size:0.8rem;font-weight:600;">OR</span>
            <label class="btn-primary" style="padding:0.55rem 1rem;font-size:0.8rem;cursor:pointer;white-space:nowrap;margin:0;">
              📁 Browse
              <input type="file" name="image" accept="image/jpeg,image/png,image/jpg,image/gif,image/webp" style="display:none;" onchange="previewFile(this,'edit_preview')">
            </label>
          </div>
          <img id="edit_preview" class="img-preview" alt="preview">
        </div>
        <div class="form-group">
          <label>Description</label>
          <textarea name="description" id="edit_description"></textarea>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Cancel</button>
        <button type="submit" class="btn-primary btn-submit">💾 Save Changes</button>
      </div>
    </form>
  </div>
</div>

{{-- ═══ DELETE CONFIRM ═══ --}}
<div class="modal-overlay" id="deleteModal" onclick="closeOnOverlay(event,'deleteModal')">
  <div class="modal" style="max-width:420px;">
    <div class="modal-head">
      <h3>🗑️ Delete Food Item</h3>
      <button class="modal-close" onclick="closeModal('deleteModal')">✕</button>
    </div>
    <div class="modal-body" style="text-align:center;padding:2rem;">
      <div style="font-size:3rem;margin-bottom:1rem;">⚠️</div>
      <p style="font-size:1rem;font-weight:600;margin-bottom:0.5rem;">Delete "<span id="deleteItemName"></span>"?</p>
      <p style="color:var(--muted);font-size:0.875rem;">This action cannot be undone.</p>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn-cancel" onclick="closeModal('deleteModal')">Cancel</button>
      <button type="button" class="btn-primary btn-submit" id="deleteConfirmBtn">🗑️ Yes, Delete</button>
    </div>
  </div>
</div>

<script>
  function openModal(id) {
    document.getElementById(id + 'Modal').classList.add('open');
    document.body.style.overflow = 'hidden';
  }
  function closeModal(id) {
    document.getElementById(id).classList.remove('open');
    document.body.style.overflow = '';
  }
  function closeOnOverlay(e, id) {
    if (e.target === document.getElementById(id)) closeModal(id);
  }
  document.addEventListener('keydown', e => { if (e.key === 'Escape') document.querySelectorAll('.modal-overlay.open').forEach(m => m.classList.remove('open')); });

  function previewImg(input, previewId) {
    const img = document.getElementById(previewId);
    const url = input.value.trim();
    if (url) { img.src = url; img.style.display = 'block'; img.onerror = () => img.style.display='none'; }
    else { img.style.display = 'none'; }
  }

  function previewFile(input, previewId) {
    const img = document.getElementById(previewId);
    const file = input.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = e => { img.src = e.target.result; img.style.display = 'block'; };
      reader.readAsDataURL(file);
      input.closest('.form-group').querySelector('input[type="url"]').value = '';
    }
  }

  function openEditModal(food) {
    document.getElementById('editForm').action = '/food/' + food.id;
    document.getElementById('edit_name').value        = food.name        || '';
    document.getElementById('edit_price').value       = food.price       || '';
    document.getElementById('edit_description').value = food.description || '';
    document.getElementById('edit_image_url').value   = food.image_url   || '';

    const cat = document.getElementById('edit_category');
    for (let i = 0; i < cat.options.length; i++) {
      cat.options[i].selected = cat.options[i].value === food.category;
    }

    const preview = document.getElementById('edit_preview');
    if (food.image_url) { preview.src = food.image_url; preview.style.display = 'block'; }
    else { preview.style.display = 'none'; }

    document.getElementById('editModal').classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  let pendingDeleteForm = null;
  function confirmDelete(event, name) {
    event.preventDefault();
    pendingDeleteForm = event.target;
    document.getElementById('deleteItemName').textContent = name;
    document.getElementById('deleteModal').classList.add('open');
    document.body.style.overflow = 'hidden';
    return false;
  }
  document.getElementById('deleteConfirmBtn').addEventListener('click', function() {
    if (pendingDeleteForm) { closeModal('deleteModal'); pendingDeleteForm.submit(); }
  });

  @if($errors->any() && old('name'))
    document.addEventListener('DOMContentLoaded', () => openModal('add'));
  @endif

  // ── Auto-accept pending orders ──
  document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.badge-pending').forEach(function(badge) {
      var row = badge.closest('tr');
      if (!row) return;
      var cells = row.querySelectorAll('td');
      if (cells.length < 4) return;
      var orderId = cells[0]?.textContent?.trim()?.replace('#', '');
      if (!orderId) return;
      var priceText = cells[3]?.textContent?.trim()?.replace('$', '')?.replace(',', '');
      var price = parseFloat(priceText) || 0;
      var delay = 3000 + Math.random() * 1000;
      setTimeout(function() {
        fetch('/orders/' + orderId + '/accept', {
          method: 'PATCH',
          headers: { 'X-CSRF-TOKEN': '{{ csrf_token() }}', 'Accept': 'application/json' }
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
          if (data.success) {
            badge.className = 'badge-status badge-accepted';
            badge.textContent = '● Accepted';
            var totalEl = document.querySelector('.stat-card.pink .stat-value');
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
@endsection
