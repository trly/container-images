# container-images

## Description

Monorepo of container images published to `ghcr.io/trly/<image>`. Each
top-level directory that contains a `Dockerfile` defines exactly one
published image; the directory name is the image name

## Managed Images

- **caddy** — [Caddy](https://caddyserver.com/) built with the
  [`caddy-dns/porkbun`](https://github.com/caddy-dns/porkbun) DNS provider
  module (via `xcaddy`), enabling DNS-01 ACME challenges through Porkbun.
  See [`caddy/Dockerfile`](caddy/Dockerfile).
- **kanboard** — Upstream [Kanboard](https://kanboard.org/) with the
  [OAuth2](https://github.com/kanboard/plugin-oauth2) and
  [MCP](https://github.com/ChristianJStarr/kanboard-mcp) plugins
  preinstalled. See [`kanboard/Dockerfile`](kanboard/Dockerfile).

The repository is intended for the maintainer's personal self-hosted
deployments; there is no application server, internal database, or runtime
API in this repo — the automation surface is GitHub Actions.

## Setup

Local tooling is managed with Mise. Image builds use Docker.

Prerequisites:

- [Mise](https://mise.jdx.dev/) (installs `hadolint`, `actionlint`, and
  `trivy` from [`.mise.toml`](.mise.toml)).
- [Docker](https://docs.docker.com/get-docker/) for building and loading
  images.

Install the local tools:

```sh
mise install
```

Build a single image (directory name == image name):

```sh
docker build -t ghcr.io/trly/<image>:<tag> <image>
```

Lint a single Dockerfile:

```sh
mise exec -- hadolint <image>/Dockerfile
```

Lint the GitHub Actions workflows:

```sh
mise exec -- actionlint
```

Scan a built image for vulnerabilities:

```sh
mise exec -- trivy image <tag>
```

Adding a new image (per [`AGENTS.md`](AGENTS.md)):

1. Create `<name>/Dockerfile`; keep the directory name equal to the
   published image name.
2. Pin the final `FROM` line to an explicit version — the image tag is
   derived from it by the image build workflows.
3. Keep `LABEL org.opencontainers.image.source=https://github.com/trly/container-images`
   in the final stage so GHCR links back to this repo.
4. Add a matching `package-ecosystem: docker` entry in
   [`.github/dependabot.yml`](.github/dependabot.yml).

## System context

CI in [`.github/workflows/test-images.yml`](.github/workflows/test-images.yml)
and [`.github/workflows/publish.yml`](.github/workflows/publish.yml) discover
changed image directories with
[`.github/actions/discover-images`](.github/actions/discover-images), then
build, scan, and pass each image artifact through its matrix. Publishing only
runs on pushes to `main`.

| Adjacent component | Relationship | Evidence |
| --- | --- | --- |
| `ghcr.io/trly/*` (GitHub Container Registry) | Downstream — publish target for every image in this repo | [`.github/workflows/publish.yml`](.github/workflows/publish.yml) |
| `docker.io/library/caddy` (builder + runtime) | Upstream base image for `caddy/` | [`caddy/Dockerfile`](caddy/Dockerfile) |
| [`caddy-dns/porkbun`](https://github.com/caddy-dns/porkbun) | Upstream Caddy plugin compiled in via `xcaddy` | [`caddy/Dockerfile`](caddy/Dockerfile) |
| `docker.io/kanboard/kanboard` | Upstream base image for `kanboard/` | [`kanboard/Dockerfile`](kanboard/Dockerfile) |
| [`kanboard/plugin-oauth2`](https://github.com/kanboard/plugin-oauth2) | Upstream plugin installed into `kanboard` image | [`kanboard/Dockerfile`](kanboard/Dockerfile) |
| [`ChristianJStarr/kanboard-mcp`](https://github.com/ChristianJStarr/kanboard-mcp) | Upstream plugin installed into `kanboard` image | [`kanboard/Dockerfile`](kanboard/Dockerfile) |
| `hadolint`, `actionlint`, `trivy` (via Mise) | Build/test tooling managed locally | [`.mise.toml`](.mise.toml) |
| Dependabot (`docker`, `github-actions`) | External — bumps base images and workflow actions | [`.github/dependabot.yml`](.github/dependabot.yml) |
