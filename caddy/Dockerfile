FROM docker.io/library/caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/porkbun

FROM docker.io/library/caddy:2.11

LABEL org.opencontainers.image.source=https://github.com/trly/container-images

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

