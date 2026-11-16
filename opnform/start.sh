#!/bin/bash
# Railway start script for OpnForm: runs the official entrypoint (migrations, keys, cache) and PHP-FPM,
# then the queue worker, the scheduler and Caddy. If any of them exits, the container exits and Railway restarts it.
set -u

: "${CLIENT_UPSTREAM:?CLIENT_UPSTREAM must point at the OpnForm client service, e.g. http://client.railway.internal:3000}"
export CLIENT_UPSTREAM

/usr/local/bin/opnform-entrypoint php-fpm &
FPM_PID=$!

echo "Waiting for PHP-FPM (after migrations) on 127.0.0.1:9000"
until (exec 3<>/dev/tcp/127.0.0.1/9000) 2>/dev/null; do
	if ! kill -0 "$FPM_PID" 2>/dev/null; then
		echo "OpnForm API setup failed" >&2
		exit 1
	fi
	sleep 1
done

cd /usr/share/nginx/html
php ./artisan app:scheduler-status --mode=record || true

php ./artisan queue:work --sleep=3 --tries=3 &
php ./artisan schedule:work &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

wait -n
echo "A process exited; stopping so Railway restarts the service" >&2
exit 1
