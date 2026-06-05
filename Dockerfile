# Build stage: runs on the build host and cross-compiles for the target platform.
# Go cross-compiles natively, so the slow compile step needs no QEMU emulation.
# Caddy version to build. CI always passes the exact version; the default lets a plain
# `docker build .` build the latest Caddy 2.
ARG CADDY_VERSION=2
FROM --platform=$BUILDPLATFORM caddy:${CADDY_VERSION}-builder AS builder
ARG TARGETOS TARGETARCH TARGETVARIANT

# Build Caddy with the PPH and Cloudflare DNS module
RUN xcaddy build \
    --with github.com/caddy-dns/pph \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/WeidiDeng/caddy-cloudflare-ip \
    --with github.com/caddy-dns/hetzner/v2 \
    --with github.com/fvbommel/caddy-combine-ip-ranges

# Slim image: our own Alpine base (the official image minus its stock binary) with the
# custom-built binary, so the image carries one Caddy binary instead of two. The builder
# sets XCADDY_SETCAP=1, so the binary already has cap_net_bind_service.
FROM ghcr.io/caddybuilds/caddy-base:latest AS slim
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Default image: the official image for the target platform with the custom-built binary.
# Kept last so a plain `docker build .` produces it.
FROM caddy:${CADDY_VERSION} AS default
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
