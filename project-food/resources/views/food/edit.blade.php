@extends('layouts.app')

@section('content')
<style>
    .edit-container { max-width: 600px; margin: 0 auto; }
    .back-link { color: var(--text-muted); font-size: 0.9rem; text-decoration: none; transition: color 0.2s; }
    .back-link:hover { color: var(--text-main); }
    .edit-title { font-size: 1.6rem; font-weight: 800; margin-top: 0.5rem; }
    .error-box { background: rgba(249,115,22,0.1); border: 1px solid rgba(249,115,22,0.2); color: var(--accent-pink); padding: 1rem; border-radius: 10px; margin-bottom: 1rem; font-weight: 500; }
    .error-box ul { margin: 0; padding-left: 1.2rem; }
    .img-upload-row { display: flex; gap: 0.5rem; align-items: center; margin-bottom: 0.5rem; }
    .img-upload-row input[type="url"] { flex: 1; }
    .img-upload-row .or { color: var(--text-muted); font-size: 0.8rem; font-weight: 600; white-space: nowrap; }
    .img-preview { width: 100%; height: 140px; border-radius: 10px; object-fit: cover; border: 1px solid var(--glass-border); margin-top: 0.5rem; display: none; }
</style>

<div class="edit-container">
    <div style="margin-bottom:1.5rem;">
        <a href="/dashboard" class="back-link">← Back to Dashboard</a>
        <h2 class="edit-title">✏️ Edit Food Item</h2>
    </div>

    @if($errors->any())
    <div class="error-box">
        <ul>
            @foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach
        </ul>
    </div>
    @endif

    <div class="card">
        <form action="/food/{{ $food->id }}" method="POST" enctype="multipart/form-data">
            @csrf @method('PATCH')
            <div style="display:flex;flex-direction:column;gap:1.2rem;">
                <div class="form-group">
                    <label>Food Name *</label>
                    <input type="text" name="name" class="form-control" value="{{ old('name', $food->name) }}" required>
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                    <div class="form-group">
                        <label>Category *</label>
                        <select name="category" class="form-control" style="background:#0a192f;color:#fff;" required>
                            @foreach(['Pizza','Burger','Sushi','Drinks','Desserts','Healthy','Asian','Chicken','Seafood','Vegetarian','Other'] as $cat)
                            <option value="{{ $cat }}" {{ old('category',$food->category)===$cat?'selected':'' }}>{{ $cat }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Price ($) *</label>
                        <input type="number" name="price" class="form-control" value="{{ old('price', $food->price) }}" step="0.01" min="0" required>
                    </div>
                </div>
                <div class="form-group">
                    <label>Image (URL or Upload)</label>
                    <div class="img-upload-row">
                        <input type="url" name="image_url" class="form-control" oninput="previewImg(this,'preview')" value="{{ old('image_url', $food->image_url) }}" placeholder="https://...">
                        <span class="or">OR</span>
                        <label class="btn btn-pink" style="padding:0.55rem 1rem;font-size:0.8rem;cursor:pointer;white-space:nowrap;margin:0;display:inline-flex;align-items:center;gap:0.3rem;">
                            📁 Browse
                            <input type="file" name="image" accept="image/jpeg,image/png,image/jpg,image/gif,image/webp" style="display:none;" onchange="previewFile(this,'preview')">
                        </label>
                    </div>
                    @php $imgSrc = $food->image ? \Storage::url($food->image) : $food->image_url; @endphp
                    <img id="preview" class="img-preview" src="{{ $imgSrc }}" style="{{ $imgSrc ? 'display:block;' : '' }}" alt="preview">
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" class="form-control" rows="3">{{ old('description', $food->description) }}</textarea>
                </div>
                <div style="display:flex;gap:0.8rem;">
                    <button type="submit" class="btn btn-pink" style="flex:1;padding:0.8rem;font-size:1rem;font-weight:700;">💾 Save Changes</button>
                    <a href="/dashboard" class="btn" style="flex:1;background:var(--glass-bg);border:1px solid var(--glass-border);color:var(--text-muted);padding:0.8rem;font-size:1rem;display:flex;align-items:center;justify-content:center;text-decoration:none;">Cancel</a>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
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
</script>
@endsection
