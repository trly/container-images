# trly/caddy

A [Caddy](https://caddyserver.com/) Docker image with the [caddy-dns/porkbun](https://github.com/caddy-dns/porkbun) and [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare) DNS provider modules included, enabling DNS-01 ACME challenges via Porkbun or Cloudflare.

## Build

```sh
docker build -t caddy-porkbun .
```
