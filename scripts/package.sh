#!/bin/sh
# Assembles the prebuilt bundle from a finished build tree.
# Usage: scripts/package.sh <build dir> <output dir> [x64|arm64]
set -eu

build="$1"
out="$2"
arch="${3:-x64}"
case "$arch" in x64) triplet=x64-linux ;; arm64) triplet=arm64-linux ;; esac
repo="$(cd "$(dirname "$0")/.." && pwd)"
sdk_version="$(git -C "$build/_deps/ziti-sdk-c-src" describe --tags --always)"
name="ziti-deps-${sdk_version}-${arch}-musl"
stage="$(mktemp -d)/$name"

mkdir -p "$stage/include" "$stage/lib/cmake/ziti-deps" "$out"
cp -a "$build/vcpkg_installed/$triplet/include/." "$stage/include/"
cp -a "$build/_deps/ziti-sdk-c-src/includes/." "$stage/include/"
cp -a "$build/_deps/tlsuv-src/include/." "$stage/include/"
cp -a "$build/_deps/tlsuv-build/generated/." "$stage/include/"
cp -a "$build/_deps/tlsuv-src/deps/uv_link_t/include/." "$stage/include/"

for lib in stc uv ssl crypto sodium json-c protobuf-c llhttp z; do
    cp "$build/vcpkg_installed/$triplet/lib/lib$lib.a" "$stage/lib/"
done
cp "$build/_deps/ziti-sdk-c-build/library/libziti.a" "$build/_deps/tlsuv-build/libtlsuv.a" "$stage/lib/"
cp "$repo/cmake/ziti-deps-config.cmake" "$stage/lib/cmake/ziti-deps/"

(cd "$(dirname "$stage")" && zip -qr "$out/$name.zip" "$name")
echo "$out/$name.zip"
