#!/bin/sh
# Runs scripts/build.sh in a pinned Alpine container, with the repo and a persistent cache mounted.
# Usage: scripts/docker-build.sh <output dir> [cache dir] [x64|arm64]
set -eu

out="$1"
cache="${2:-$PWD/.cache}"
arch="${3:-x64}"
case "$arch" in x64) platform=linux/amd64 ;; arm64) platform=linux/arm64 ;; esac
repo="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$out" "$cache"

docker run --rm --platform "$platform" \
    -v "$repo:/src/ziti-sdk-c-deps" \
    -v "$(cd "$out" && pwd):/out" \
    -v "$(cd "$cache" && pwd):/cache" \
    alpine:3.22 sh /src/ziti-sdk-c-deps/scripts/build.sh /out "$arch"
