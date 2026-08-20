@extends('layouts.app')

@section('content')
<style>
    .register-container {
        display: flex;
        min-height: 80vh;
        align-items: center;
        justify-content: center;
        padding: 2rem;
    }
    .register-card {
        display: flex;
        width: 1000px;
        background: rgba(255, 255, 255, 0.03);
        backdrop-filter: blur(30px);
        -webkit-backdrop-filter: blur(30px);
        border-radius: 24px;
        overflow: hidden;
        box-shadow: 0 25px 60px -12px rgba(0, 0, 0, 0.5);
        border: 1px solid rgba(255, 255, 255, 0.06);
    }
    .register-branding {
        flex: 1;
        position: relative;
        display: none;
    }
    .register-branding img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    .register-branding-overlay {
        position: absolute;
        inset: 0;
        background: linear-gradient(to top, rgba(8, 8, 24, 0.95), rgba(8, 8, 24, 0.3));
        display: flex;
        flex-direction: column;
        justify-content: flex-end;
        padding: 3rem;
    }
    .register-form-wrap {
        flex: 1;
        padding: 3rem 4rem;
        display: flex;
        flex-direction: column;
        justify-content: center;
    }
    .register-form-wrap h2 {
        font-size: 2.2rem;
        font-weight: 800;
        color: var(--text-main);
        margin-bottom: 0.5rem;
        letter-spacing: -1px;
    }
    .register-form-wrap > .subtitle {
        color: var(--text-muted);
        font-weight: 500;
        margin-bottom: 2rem;
    }
    .register-error {
        background: rgba(249, 115, 22, 0.1);
        border: 1px solid rgba(249, 115, 22, 0.2);
        color: var(--accent-pink);
        padding: 1rem 1.2rem;
        border-radius: 12px;
        margin-bottom: 2rem;
        font-weight: 500;
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
    }
    .register-error ul {
        margin: 0;
        padding-left: 1.2rem;
    }
    .form-row-2 {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 1rem;
    }
    .role-select {
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='white' viewBox='0 0 16 16'%3E%3Cpath d='M8 11L3 6h10z'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 1rem center;
        padding-right: 2.5rem;
        cursor: pointer;
    }
    .role-select option {
        background: #0d0d24;
        color: white;
    }
    .btn-register {
        width: 100%;
        padding: 1rem;
        font-size: 1rem;
        font-weight: 800;
        border-radius: 12px;
        letter-spacing: 0.3px;
        transition: all 0.3s;
        border: none;
        cursor: pointer;
        font-family: 'Inter', sans-serif;
        background: linear-gradient(135deg, var(--accent-pink), #fb923c);
        color: white;
        box-shadow: 0 8px 25px rgba(249, 115, 22, 0.3);
    }
    .btn-register:hover {
        transform: translateY(-2px);
        box-shadow: 0 12px 35px rgba(249, 115, 22, 0.4);
    }
    .register-footer {
        margin-top: 2rem;
        text-align: center;
        border-top: 1px solid rgba(255, 255, 255, 0.06);
        padding-top: 2rem;
    }
    .register-footer a {
        color: var(--accent-pink);
        font-weight: 700;
        text-decoration: none;
        transition: opacity 0.2s;
    }
    .register-footer a:hover {
        opacity: 0.8;
    }
    .input-group {
        position: relative;
    }
    .input-icon {
        position: absolute;
        left: 1rem;
        top: 50%;
        transform: translateY(-50%);
        color: rgba(255, 255, 255, 0.2);
        font-size: 1rem;
        pointer-events: none;
    }
    .input-group .form-control {
        padding-left: 2.8rem;
    }
    @media (min-width: 768px) {
        .register-branding {
            display: block;
        }
    }
</style>

<div class="register-container">
    <div class="register-card">
        <div class="register-branding">
            <img src="https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1000&auto=format&fit=crop" alt="Register">
            <div class="register-branding-overlay">
                <h2 style="font-size:2.5rem;font-weight:800;color:white;margin-bottom:1rem;line-height:1.2;">Start Your <span style="color:var(--accent-pink);text-shadow:0 0 30px rgba(255,61,113,0.5);">Food</span> Journey.</h2>
                <p style="color:rgba(255,255,255,0.7);font-size:1.05rem;font-weight:500;">Join thousands of food lovers and vendors on FoodX.</p>
            </div>
        </div>

        <div class="register-form-wrap">
            <h2>Join FoodX</h2>
            <p class="subtitle">Create your account to get started</p>

            @if ($errors->any())
                <div class="register-error">
                    <ul>
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form action="/register" method="POST">
                @csrf
                <div class="form-group">
                    <label>Full Name</label>
                    <div class="input-group">
                        <span class="input-icon">👤</span>
                        <input type="text" name="name" class="form-control" placeholder="John Doe" required value="{{ old('name') }}">
                    </div>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <div class="input-group">
                        <span class="input-icon">✉</span>
                        <input type="email" name="email" class="form-control" placeholder="name@example.com" required value="{{ old('email') }}">
                    </div>
                </div>
                <div class="form-row-2">
                    <div class="form-group">
                        <label>Password</label>
                        <div class="input-group">
                            <span class="input-icon">🔒</span>
                            <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Confirm Password</label>
                        <div class="input-group">
                            <span class="input-icon">🔒</span>
                            <input type="password" name="password_confirmation" class="form-control" placeholder="••••••••" required>
                        </div>
                    </div>
                </div>
                <div class="form-group" style="margin-bottom:2rem;">
                    <label>Register as:</label>
                    <select name="role" class="form-control role-select" required>
                        <option value="user" {{ old('role')=='user'?'selected':'' }}>🛒 Customer (Order food)</option>
                        <option value="seller" {{ old('role')=='seller'?'selected':'' }}>🍽️ Seller (Sell food)</option>
                        <option value="admin" {{ old('role')=='admin'?'selected':'' }}>⚙️ Administrator</option>
                    </select>
                </div>
                <button type="submit" class="btn-register">Create Account</button>
            </form>

            <div class="register-footer">
                <p style="color:var(--text-muted);font-weight:500;">
                    Already have an account? <a href="/login">Sign In</a>
                </p>
            </div>
        </div>
    </div>
</div>
@endsection
