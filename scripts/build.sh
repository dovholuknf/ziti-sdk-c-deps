#!/bin/sh
# Builds libziti and its dependencies as static musl libraries on Alpine and packages them into a zip.
# Usage: scripts/build.sh <output dir>
#
# Every path and tool version that can reach vcpkg's ABI hash is fixed here, so the binary cache hits from any
# checkout, container, or machine: vcpkg lives at /opt/vcpkg, the sources at /src/ziti-sdk-c-deps, the build at /build,
# PATH is set below, and the vcpkg commit is pinned.
set -eu

out="$1"
repo_dir=/src/ziti-sdk-c-deps
vcpkg_commit=c3867e714dd3a51c272826eea77267876517ed99

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export VCPKG_ROOT=/opt/vcpkg VCPKG_FORCE_SYSTEM_BINARIES=1
export VCPKG_DEFAULT_BINARY_CACHE="${VCPKG_DEFAULT_BINARY_CACHE:-/cache/vcpkg}"

here="$(cd "$(dirname "$0")/.." && pwd)"
if [ "$here" != "$repo_dir" ]; then
    mkdir -p "$repo_dir"
    cp -a "$here/." "$repo_dir/"
fi
mkdir -p "$VCPKG_DEFAULT_BINARY_CACHE"

apk add --no-cache build-base cmake ninja-is-really-ninja autoconf autoconf-archive automake libtool git curl zip \
    unzip tar pkgconf linux-headers perl bash python3

if [ ! -d "$VCPKG_ROOT" ]; then
    git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT"
    git -C "$VCPKG_ROOT" checkout "$vcpkg_commit"
fi
[ -x "$VCPKG_ROOT/vcpkg" ] || "$VCPKG_ROOT/bootstrap-vcpkg.sh" -disableMetrics

cd "$repo_dir"
cmake --preset musl-x64
cmake --build /build

sh "$repo_dir/scripts/package.sh" /build "$out"
