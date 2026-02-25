# AGENTS.md

## Project Overview
Monorepo of custom Docker images published to `ghcr.io/trly/<image>`. Each subdirectory (e.g., `caddy/`) contains a `Dockerfile` and optional `README.md`. Currently ships a Caddy image with the `caddy-dns/porkbun` module.

## Build / Lint / Test
- **Build an image:** `docker build -t <name> <dir>` (e.g., `docker build -t caddy-porkbun caddy`)
- **Lint a Dockerfile:** `hadolint <dir>/Dockerfile` (install via `mise install`)
- **Scan for vulnerabilities:** `trivy image <image-ref>`
- **Tools:** managed by [mise](https://mise.jdx.dev/) — run `mise install` to set up `hadolint` and `trivy`.

## CI Pipeline (`.github/workflows/docker.yml`)
Auto-discovers images by finding `Dockerfile`s → runs Hadolint → builds → Trivy scan → pushes to GHCR on `main`.

## Adding a New Image
Create `<name>/Dockerfile` — the CI workflow discovers it automatically. The image tag is extracted from the final `FROM` stage's tag. You must also add a corresponding `package-ecosystem: docker` entry in `.github/dependabot.yml` for the new directory, as Dependabot doesn't support dynamic discovery. Include `LABEL org.opencontainers.image.source=https://github.com/trly/container-images` in the final stage to link the GHCR package to this repository.

## Code Style
- Keep Dockerfiles minimal; use multi-stage builds when compiling from source.
- Follow [Hadolint](https://github.com/hadolint/hadolint) best practices (the linter enforces this).
- Pin base image tags to specific versions (e.g., `caddy:2.11`, not `caddy:latest`).
- Exclude non-essential files from the build context via `.dockerignore`.
