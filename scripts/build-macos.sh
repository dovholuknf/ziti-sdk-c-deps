#!/bin/sh
# Builds libziti and its dependencies as static libraries on macOS with vcpkg and packages them into a zip.
# Usage: scripts/build-macos.sh <output dir> <scratch dir> [arm64|x64]
set -eu

out="$1"
work="$2"
arch="${3:-arm64}"
vcpkg_commit=c3867e714dd3a51c272826eea77267876517ed99
repo="$(cd "$(dirname "$0")/.." && pwd)"
vcpkg="$work/vcpkg"
build="$work/build-$arch"

export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
case "$arch" in x64) osx_arch=x86_64 ;; arm64) osx_arch=arm64 ;; esac
mkdir -p "$work" "$out"

if [ ! -d "$vcpkg" ]; then
    git clone https://github.com/microsoft/vcpkg "$vcpkg"
    git -C "$vcpkg" reset --hard "$vcpkg_commit"
fi
[ -x "$vcpkg/vcpkg" ] || "$vcpkg/bootstrap-vcpkg.sh" -disableMetrics

export VCPKG_ROOT="$vcpkg"
cmake -S "$repo" -B "$build" -G Ninja -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DCMAKE_TOOLCHAIN_FILE="$vcpkg/scripts/buildsystems/vcpkg.cmake" \
    -DVCPKG_TARGET_TRIPLET="$arch-osx" -DCMAKE_OSX_ARCHITECTURES="$osx_arch" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0
cmake --build "$build"

sh "$repo/scripts/package.sh" "$build" "$out" "$arch" macos
