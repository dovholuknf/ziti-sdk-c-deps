#!/bin/sh
# Runs scripts/build.sh in a pinned Alpine container, with the repo and a persistent cache mounted.
# Usage: scripts/docker-build.sh <output dir> [cache dir]
set -eu

out="$1"
cache="${2:-$PWD/.cache}"
repo="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$out" "$cache"

docker run --rm \
    -v "$repo:/src/ziti-sdk-c-deps" \
    -v "$(cd "$out" && pwd):/out" \
    -v "$(cd "$cache" && pwd):/cache" \
    alpine:3.22 sh /src/ziti-sdk-c-deps/scripts/build.sh /out
