FROM php:8.2-cli-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        ca-certificates \
        curl \
    && docker-php-ext-install curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN mkdir -p /data var/data var/rate \
    && chmod -R 777 /data var/data var/rate

ENV PORT=8080
ENV FLY_APP_NAME=welcome-locaweb

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT}/" || exit 1

CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8080} router.php"]
