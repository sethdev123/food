#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../project-food"
LARAVEL_PORT=8000
LARAVEL_PID=""

cleanup() {
    echo ""
    echo "Shutting down..."
    if [ -n "$LARAVEL_PID" ] && kill -0 "$LARAVEL_PID" 2>/dev/null; then
        kill "$LARAVEL_PID" 2>/dev/null
        echo "Laravel server stopped (PID: $LARAVEL_PID)"
    fi
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

echo "=== Starting Laravel Backend ==="
cd "$BACKEND_DIR"
php artisan serve --host=0.0.0.0 --port=$LARAVEL_PORT &
LARAVEL_PID=$!
echo "Laravel server starting (PID: $LARAVEL_PID)..."

for i in $(seq 1 30); do
    if curl -s "http://127.0.0.1:$LARAVEL_PORT" > /dev/null 2>&1; then
        echo "Laravel is ready at http://127.0.0.1:$LARAVEL_PORT"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "Timed out waiting for Laravel to start."
        exit 1
    fi
    sleep 1
done

echo ""
echo "=== Starting Flutter App ==="
cd "$SCRIPT_DIR"
flutter run -d linux
