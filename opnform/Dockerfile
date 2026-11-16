# OpnForm API (Laravel, PHP-FPM) + queue worker + scheduler + Caddy front proxy in one service,
# so the PHP processes share one storage volume (Railway volumes attach to a single service).
FROM caddy:2.11.9@sha256:4e2425f6009577e7c651010f16679c28f7d12df3e7b1914f941a7a3370746b3c AS caddy

FROM jhumanj/opnform-api:2.8.4@sha256:75e0db0329b80b275b20611ee9a2a4a9ad2848ca5e45abaa84af05fe124f6a8a

COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY zzz-railway.conf /usr/local/etc/php-fpm.d/zzz-railway.conf
COPY start.sh /usr/local/bin/opnform-railway-start
RUN chmod +x /usr/local/bin/opnform-railway-start /usr/local/bin/caddy

# Fixed settings (deployers rarely need to change these; override with a service variable if you do)
ENV APP_ENV=production \
    APP_DEBUG=false \
    SELF_HOSTED=true \
    DB_CONNECTION=pgsql \
    CACHE_DRIVER=redis \
    CACHE_STORE=redis \
    QUEUE_CONNECTION=redis \
    SESSION_DRIVER=redis \
    LOG_CHANNEL=errorlog \
    LOG_LEVEL=warning \
    FILESYSTEM_DRIVER=local \
    LOCAL_FILESYSTEM_VISIBILITY=public \
    MAIL_MAILER=log \
    MAIL_FROM_NAME=OpnForm \
    JWT_TTL=1440 \
    JWT_SKIP_IP_UA_VALIDATION=false \
    TRUSTED_PROXIES=127.0.0.1 \
    SHOW_OFFICIAL_TEMPLATES=true \
    PHP_MEMORY_LIMIT=1G \
    PHP_MAX_EXECUTION_TIME=600 \
    PHP_UPLOAD_MAX_FILESIZE=64M \
    PHP_POST_MAX_SIZE=64M \
    PORT=8080

ENTRYPOINT []
CMD ["/usr/local/bin/opnform-railway-start"]
