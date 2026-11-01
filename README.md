# ziti-sdk-c-deps

Prebuilt static `libziti` and everything it links (tlsuv, libuv, openssl, libsodium, json-c, protobuf-c, llhttp, zlib,
stc), published as a zip per ziti-sdk-c version and platform: musl (x64, arm64), macOS (arm64, x64) and Windows (x64).
Link it into a small static binary without building the SDK.

## Use it

```cmake
include(FetchContent)
FetchContent_Declare(ziti-deps
        URL https://github.com/dovholuknf/ziti-sdk-c-deps/releases/download/sdk-1.20.1-1/ziti-deps-1.20.1-x64-musl.zip)
FetchContent_MakeAvailable(ziti-deps)

list(APPEND CMAKE_PREFIX_PATH ${ziti-deps_SOURCE_DIR})
find_package(ziti-deps CONFIG REQUIRED)

add_executable(app app.c)
target_link_libraries(app PRIVATE ziti-deps::ziti)
target_link_options(app PRIVATE -static)
```

Build the consumer on musl (Alpine). The libraries are musl objects, so they do not link against glibc.

## Build the bundle

```sh
scripts/docker-build.sh out        # needs Docker; writes out/ziti-deps-<sdk version>-x64-musl.zip
scripts/publish.sh sdk-1.20.1-1 out
```

macOS: `scripts/build-macos.sh out work [arm64|x64]`. Windows: `scripts/build-windows.ps1 -Out out -Work work`.
Zips are named `ziti-deps-<sdk version>-<arch>-<musl|macos|windows>.zip`.

Or run the `release` workflow, which calls the same scripts.

## The build is pinned

vcpkg keys its binary cache on an ABI hash, and a path or environment difference changes the hash. So
`scripts/build.sh` builds at fixed locations whatever the checkout: vcpkg at `/opt/vcpkg` (pinned commit), sources at
`/src/ziti-sdk-c-deps`, build at `/build`, a fixed `PATH`, and Alpine 3.22. `CMakePresets.json` fixes the binary
directory, toolchain file and triplet. Change the SDK version with `-DZITI_SDK_VERSION=<tag>`.
