<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ config('app.name', 'S&V Kitchen') }}</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-primary: #080818;
            --bg-secondary: #0d0d24;
            --glass-bg: rgba(255, 255, 255, 0.04);
            --glass-border: rgba(255, 255, 255, 0.08);
            --glass-hover: rgba(255, 255, 255, 0.07);
            --sidebar-glass: rgba(255, 255, 255, 0.03);
            --sidebar-border: rgba(255, 255, 255, 0.06);
            --text-main: #f0f0f5;
            --text-muted: #8888aa;
            --accent-pink: #f97316;
            --accent-pink-glow: rgba(249, 115, 22, 0.25);
            --accent-blue: #4da6ff;
            --accent-green: #00d68f;
            --accent-yellow: #ffaa00;
            --radius: 16px;
            --radius-sm: 10px;
            --shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-primary);
            color: var(--text-main);
            display: flex;
            min-height: 100vh;
            overflow-x: hidden;
            background-image:
                radial-gradient(ellipse at 20% 50%, rgba(249, 115, 22, 0.06) 0%, transparent 50%),
                radial-gradient(ellipse at 80% 20%, rgba(77, 166, 255, 0.06) 0%, transparent 50%),
                radial-gradient(ellipse at 50% 80%, rgba(0, 214, 143, 0.04) 0%, transparent 50%);
        }

        /* ── Sidebar ── */
        .sidebar {
            width: 260px;
            background: var(--sidebar-glass);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            display: flex;
            flex-direction: column;
            padding: 1.5rem;
            position: fixed;
            height: 100vh;
            left: 0;
            top: 0;
            z-index: 100;
            border-right: 1px solid var(--sidebar-border);
        }

        .logo {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--text-main);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 2.5rem;
            letter-spacing: -0.5px;
        }

        .logo span {
            color: var(--accent-pink);
            text-shadow: 0 0 20px var(--accent-pink-glow);
        }

        .nav-links {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 0.3rem;
        }

        .nav-item {
            text-decoration: none;
            color: var(--text-muted);
            padding: 0.75rem 1rem;
            border-radius: var(--radius-sm);
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 0.85rem;
            transition: all 0.25s ease;
            font-size: 0.9rem;
            border: 1px solid transparent;
        }

        .nav-item:hover {
            background: var(--glass-bg);
            border-color: var(--glass-border);
            color: var(--text-main);
        }

        .nav-item.active {
            background: var(--accent-pink-glow);
            border-color: rgba(249, 115, 22, 0.2);
            color: var(--accent-pink);
        }

        .nav-section {
            margin: 1.2rem 0 0.5rem;
            padding: 0 1rem;
            font-size: 0.65rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: rgba(255, 255, 255, 0.2);
        }

        /* ── Main Content ── */
        .main-content {
            flex: 1;
            margin-left: 260px;
            padding: 2rem;
            width: calc(100% - 260px);
        }

        /* ── Top Bar ── */
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2.5rem;
        }

        .search-box {
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            padding: 0.75rem 1.5rem;
            border-radius: 50px;
            color: white;
            width: 300px;
            outline: none;
            font-family: 'Inter', sans-serif;
            font-size: 0.85rem;
            transition: all 0.25s;
        }

        .search-box:focus {
            border-color: var(--accent-pink);
            box-shadow: 0 0 20px var(--accent-pink-glow);
        }

        .search-box::placeholder {
            color: rgba(255, 255, 255, 0.2);
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-info {
            text-align: right;
        }

        .user-name {
            font-weight: 600;
            font-size: 0.9rem;
        }

        .user-role {
            font-size: 0.7rem;
            color: var(--accent-pink);
            text-transform: uppercase;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .avatar {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--accent-pink), #fb923c);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 0.9rem;
            box-shadow: 0 0 20px var(--accent-pink-glow);
        }

        /* ── Dashboard Grid ── */
        .grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.5rem;
        }

        /* ── Glass Card ── */
        .card {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            padding: 1.5rem;
            border-radius: var(--radius);
            transition: all 0.3s ease;
        }

        .card:hover {
            border-color: rgba(255, 255, 255, 0.12);
            box-shadow: var(--shadow);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 1.5rem;
            color: var(--text-muted);
            font-size: 0.85rem;
            font-weight: 600;
        }

        .card-value {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            letter-spacing: -1px;
        }

        .card-sub {
            font-size: 0.8rem;
            color: var(--text-muted);
        }

        .icon-box {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }

        .bg-pink {
            background: rgba(249, 115, 22, 0.15);
            color: var(--accent-pink);
            box-shadow: 0 0 20px rgba(249, 115, 22, 0.1);
        }
        .bg-blue {
            background: rgba(77, 166, 255, 0.15);
            color: var(--accent-blue);
            box-shadow: 0 0 20px rgba(77, 166, 255, 0.1);
        }
        .bg-green {
            background: rgba(0, 214, 143, 0.15);
            color: var(--accent-green);
            box-shadow: 0 0 20px rgba(0, 214, 143, 0.1);
        }

        .card-title {
            font-size: 1.05rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
        }

        .list-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.8rem 0;
            border-bottom: 1px solid var(--glass-border);
        }

        .list-item:last-child {
            border-bottom: none;
        }

        .badge {
            padding: 0.3rem 0.7rem;
            border-radius: 20px;
            font-size: 0.7rem;
            font-weight: 700;
        }

        .badge-green {
            background: rgba(0, 214, 143, 0.1);
            color: var(--accent-green);
        }

        .btn {
            padding: 0.6rem 1.2rem;
            border-radius: var(--radius-sm);
            font-weight: 600;
            cursor: pointer;
            border: none;
            transition: all 0.25s;
            font-size: 0.85rem;
            font-family: 'Inter', sans-serif;
        }

        .btn-pink {
            background: linear-gradient(135deg, var(--accent-pink), #fb923c);
            color: white;
            box-shadow: 0 4px 15px var(--accent-pink-glow);
        }

        .btn-pink:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px var(--accent-pink-glow);
        }

        /* ── Tables (shared) ── */
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }
        thead tr {
            border-bottom: 1px solid var(--glass-border);
        }
        th {
            padding: 0.8rem 1rem;
            color: var(--text-muted);
            font-weight: 600;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            text-align: left;
        }
        tbody tr {
            border-bottom: 1px solid var(--glass-border);
            transition: background 0.2s;
        }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: var(--glass-hover); }
        td { padding: 0.85rem 1rem; }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }
        .status-pending {
            background: rgba(255, 170, 0, 0.1);
            color: var(--accent-yellow);
            border: 1px solid rgba(255, 170, 0, 0.15);
        }
        .status-accepted {
            background: rgba(77, 166, 255, 0.1);
            color: var(--accent-blue);
            border: 1px solid rgba(77, 166, 255, 0.15);
        }
        .status-completed {
            background: rgba(0, 214, 143, 0.1);
            color: var(--accent-green);
            border: 1px solid rgba(0, 214, 143, 0.15);
        }
        .status-cancelled {
            background: rgba(249, 115, 22, 0.1);
            color: var(--accent-pink);
            border: 1px solid rgba(249, 115, 22, 0.15);
        }

        /* ── Form inputs ── */
        .form-control {
            width: 100%;
            padding: 0.8rem 1.2rem;
            border-radius: var(--radius-sm);
            border: 1px solid var(--glass-border);
            background: var(--glass-bg);
            color: var(--text-main);
            font-size: 0.9rem;
            outline: none;
            transition: all 0.25s;
            font-family: 'Inter', sans-serif;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }
        .form-control:focus {
            border-color: var(--accent-pink);
            box-shadow: 0 0 0 3px var(--accent-pink-glow);
        }
        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.2);
        }
        .form-group {
            margin-bottom: 1.5rem;
        }
        .form-group label {
            display: block;
            color: var(--text-muted);
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 700;
            margin-bottom: 0.6rem;
        }

        /* ── Chart -- */
        .chart-placeholder {
            width: 100%;
            height: 200px;
            background: linear-gradient(0deg, rgba(249, 115, 22, 0.06) 0%, transparent 100%);
            margin-top: 1rem;
            border-radius: var(--radius-sm);
            position: relative;
        }

        /* ── Nav bar (guest) ── */
        .guest-nav {
            display: flex;
            justify-content: space-between;
            margin-bottom: 2rem;
            align-items: center;
        }
        .guest-nav .logo {
            margin-bottom: 0;
        }
        .guest-actions {
            display: flex;
            gap: 0.8rem;
        }

        .floating-bar {
            position: fixed;
            bottom: 2rem;
            left: 50%;
            transform: translateX(-50%);
            background: var(--glass-bg);
            backdrop-filter: blur(30px);
            -webkit-backdrop-filter: blur(30px);
            border: 1px solid var(--glass-border);
            padding: 0.8rem 2rem;
            border-radius: 50px;
            display: flex;
            gap: 2rem;
            box-shadow: var(--shadow);
            z-index: 1000;
        }

        .floating-bar a {
            color: var(--text-muted);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            transition: color 0.2s;
        }

        .floating-bar a:hover {
            color: var(--text-main);
        }
    </style>
</head>
<body>
    @auth
    <div class="sidebar">
        <a href="/" class="logo">Food<span>X</span></a>
        <nav class="nav-links">
            <a href="/dashboard" class="nav-item {{ request()->is('dashboard') ? 'active' : '' }}">
                📊 Dashboard
            </a>
            @if(Auth::user()->role === 'seller')
            <div class="nav-section">My Store</div>
            <a href="/dashboard" class="nav-item">
                🍽️ My Menu
            </a>
            <a href="/food/create" class="nav-item">
                ➕ Add Food Item
            </a>
            @endif
            @if(Auth::user()->role === 'admin')
            <div class="nav-section">Admin</div>
            <a href="/food/create" class="nav-item">
                ➕ Add Food Item
            </a>
            @endif
            <div style="margin-top:auto;"></div>
            <form action="/logout" method="POST">
                @csrf
                <button type="submit" class="nav-item" style="width:100%;background:none;border:none;cursor:pointer;text-align:left;color:rgba(255,80,80,0.7);">
                    🚪 Logout
                </button>
            </form>
        </nav>
    </div>
    @endauth

    <div class="main-content" style="{{ Auth::check() ? '' : 'margin-left: 0; width: 100%;' }}">
        @auth
        <div class="top-bar">
            <input type="text" class="search-box" placeholder="Search orders, sales...">
            <div class="user-profile">
                <div class="user-info">
                    <div class="user-name">{{ Auth::user()->name }}</div>
                    <div class="user-role">{{ Auth::user()->role }}</div>
                </div>
                <div class="avatar">{{ substr(Auth::user()->name, 0, 1) }}</div>
            </div>
        </div>
        @else
        <div class="guest-nav">
             <a href="{{ route('login') }}" class="logo">Food<span>X</span></a>
        </div>
        @endauth

        @yield('content')
    </div>

    @auth
    <div style="position:fixed;bottom:1.5rem;right:1.5rem;background:var(--glass-bg);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);border:1px solid var(--glass-border);color:var(--accent-pink);padding:0.4rem 0.9rem;border-radius:20px;font-size:0.7rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;z-index:999;box-shadow:var(--shadow);">
        {{ Auth::user()->role }}
    </div>
    @endauth
    @stack('scripts')
</body>
</html>
