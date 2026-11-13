#!/usr/bin/env bash
# Serve the Flutter app as a web app so it can be opened in Safari on an
# iPhone connected to the same Wi-Fi as this machine.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../project-food"
BACKEND_PORT=8000
WEB_PORT=8080

LAN_IP="$(hostname -I | awk '{print $1}')"

cleanup() {
  echo ""
  echo "Stopping servers..."
  [ -n "$LARAVEL_PID" ] && kill "$LARAVEL_PID" 2>/dev/null || true
  [ -n "$WEB_PID" ] && kill "$WEB_PID" 2>/dev/null || true
}
trap cleanup SIGINT SIGTERM EXIT

echo "=== Backend ==="
if curl -s "http://127.0.0.1:$BACKEND_PORT" >/dev/null 2>&1; then
  echo "Laravel already running on port $BACKEND_PORT"
else
  (cd "$BACKEND_DIR" && php artisan serve --host=0.0.0.0 --port=$BACKEND_PORT) &
  LARAVEL_PID=$!
  echo "Laravel started (PID $LARAVEL_PID)"
fi

echo "=== Building web app ==="
cd "$SCRIPT_DIR"
flutter build web --release

echo "=== Serving web app ==="
(cd "$SCRIPT_DIR/build/web" && python3 -m http.server "$WEB_PORT" --bind 0.0.0.0) &
WEB_PID=$!

echo ""
echo "Open this on your iPhone (Safari), on the same Wi-Fi:"
echo "    http://$LAN_IP:$WEB_PORT"
echo ""
echo "Backend API: http://$LAN_IP:$BACKEND_PORT/api"
echo "Press Ctrl+C to stop."
wait
