FROM docker.io/library/caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/porkbun \
    --replace golang.org/x/net=golang.org/x/net@v0.62.0

FROM docker.io/library/caddy:2.11.9

RUN apk update --no-cache && apk upgrade --no-cache

LABEL org.opencontainers.image.source=https://github.com/trly/container-images

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

