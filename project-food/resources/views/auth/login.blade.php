@extends('layouts.app')

@section('content')
<style>
    .auth-container {
        display: flex;
        min-height: 80vh;
        align-items: center;
        justify-content: center;
        padding: 2rem;
    }
    .auth-card {
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
    .auth-branding {
        flex: 1;
        position: relative;
        display: none;
    }
    .auth-branding img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    .auth-branding-overlay {
        position: absolute;
        inset: 0;
        background: linear-gradient(to top, rgba(8, 8, 24, 0.95), rgba(8, 8, 24, 0.3));
        display: flex;
        flex-direction: column;
        justify-content: flex-end;
        padding: 3rem;
    }
    .auth-form-wrap {
        flex: 1;
        padding: 4rem;
        display: flex;
        flex-direction: column;
        justify-content: center;
    }
    .auth-form-wrap h2 {
        font-size: 2.2rem;
        font-weight: 800;
        color: var(--text-main);
        margin-bottom: 0.5rem;
        letter-spacing: -1px;
    }
    .auth-form-wrap .subtitle {
        color: var(--text-muted);
        font-weight: 500;
        margin-bottom: 2.5rem;
    }
    .auth-error {
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
    .auth-error ul {
        margin: 0;
        padding-left: 1.2rem;
    }
    .forgot-link {
        font-size: 0.85rem;
        color: var(--accent-pink);
        font-weight: 700;
        text-decoration: none;
        transition: opacity 0.2s;
    }
    .forgot-link:hover {
        opacity: 0.8;
    }
    .btn-submit {
        width: 100%;
        padding: 1.1rem;
        font-size: 1.05rem;
        font-weight: 800;
        border-radius: 14px;
        letter-spacing: 0.5px;
        transition: all 0.3s;
        border: none;
        cursor: pointer;
        font-family: 'Inter', sans-serif;
        background: linear-gradient(135deg, var(--accent-pink), #fb923c);
        color: white;
        box-shadow: 0 8px 25px rgba(249, 115, 22, 0.3);
    }
    .btn-submit:hover {
        transform: translateY(-2px);
        box-shadow: 0 12px 35px rgba(249, 115, 22, 0.4);
    }
    .auth-footer {
        margin-top: 2.5rem;
        text-align: center;
    }
    .auth-footer p {
        color: var(--text-muted);
        font-weight: 500;
    }
    .auth-footer a {
        color: var(--accent-pink);
        font-weight: 800;
        text-decoration: none;
        margin-left: 0.5rem;
        border-bottom: 2px solid transparent;
        transition: border-color 0.2s;
    }
    .auth-footer a:hover {
        border-bottom-color: var(--accent-pink);
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
        font-size: 1.1rem;
        pointer-events: none;
    }
    .input-group .form-control {
        padding-left: 2.8rem;
    }
    @media (min-width: 768px) {
        .auth-branding {
            display: block;
        }
    }
</style>

<div class="auth-container">
    <div class="auth-card">
        <div class="auth-branding">
            <img src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=1000&auto=format&fit=crop" alt="Food background">
            <div class="auth-branding-overlay">
                <h2 style="font-size:2.5rem;font-weight:800;color:white;margin-bottom:1rem;line-height:1.2;">Elevate Your <span style="color:var(--accent-pink);text-shadow:0 0 30px rgba(255,61,113,0.5);">Dining</span> Experience.</h2>
                <p style="color:rgba(255,255,255,0.7);font-size:1.05rem;font-weight:500;">Access the world's most sophisticated food management platform.</p>
            </div>
        </div>

        <div class="auth-form-wrap">
            <h2>Sign In</h2>
            <p class="subtitle">Enter your credentials to manage your account</p>

            @if ($errors->any())
                <div class="auth-error">
                    <ul>
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form action="/login" method="POST">
                @csrf
                <div class="form-group">
                    <label>Email Address</label>
                    <div class="input-group">
                        <span class="input-icon">✉</span>
                        <input type="email" name="email" class="form-control" placeholder="admin@foodx.com" required value="{{ old('email') }}">
                    </div>
                </div>

                <div class="form-group">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:0.6rem;">
                        <label style="margin-bottom:0;">Password</label>
                        <a href="#" class="forgot-link">Forgot?</a>
                    </div>
                    <div class="input-group">
                        <span class="input-icon">🔒</span>
                        <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                    </div>
                </div>

                <button type="submit" class="btn-submit">Access Dashboard</button>
            </form>

            <div class="auth-footer">
                <p>
                    Don't have an account yet?
                    <a href="/register">Create Account</a>
                </p>
            </div>
        </div>
    </div>
</div>
@endsection
