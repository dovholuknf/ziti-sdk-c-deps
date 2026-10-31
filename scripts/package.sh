#!/bin/sh
# Assembles the prebuilt bundle from a finished build tree.
# Usage: scripts/package.sh <build dir> <output dir>
set -eu

build="$1"
out="$2"
repo="$(cd "$(dirname "$0")/.." && pwd)"
sdk_version="$(git -C "$build/_deps/ziti-sdk-c-src" describe --tags --always)"
name="ziti-deps-${sdk_version}-x64-musl"
stage="$(mktemp -d)/$name"

mkdir -p "$stage/include" "$stage/lib/cmake/ziti-deps" "$out"
cp -a "$build/vcpkg_installed/x64-linux/include/." "$stage/include/"
cp -a "$build/_deps/ziti-sdk-c-src/includes/." "$stage/include/"
cp -a "$build/_deps/tlsuv-src/include/." "$stage/include/"
cp -a "$build/_deps/tlsuv-build/generated/." "$stage/include/"
cp -a "$build/_deps/tlsuv-src/deps/uv_link_t/include/." "$stage/include/"

for lib in stc uv ssl crypto sodium json-c protobuf-c llhttp z; do
    cp "$build/vcpkg_installed/x64-linux/lib/lib$lib.a" "$stage/lib/"
done
cp "$build/_deps/ziti-sdk-c-build/library/libziti.a" "$build/_deps/tlsuv-build/libtlsuv.a" "$stage/lib/"
cp "$repo/cmake/ziti-deps-config.cmake" "$stage/lib/cmake/ziti-deps/"

(cd "$(dirname "$stage")" && zip -qr "$out/$name.zip" "$name")
echo "$out/$name.zip"
