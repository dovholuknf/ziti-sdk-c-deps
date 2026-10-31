# Assembles the prebuilt Windows bundle from a finished build tree.
# Usage: scripts/package-windows.ps1 -Build <build dir> -Out <output dir> [-Arch x64|arm64]
param(
    [Parameter(Mandatory)] [string] $Build,
    [Parameter(Mandatory)] [string] $Out,
    [ValidateSet('x64', 'arm64')] [string] $Arch = 'x64'
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$triplet = "$Arch-windows-static"
$sdkVersion = (git -C "$Build/_deps/ziti-sdk-c-src" describe --tags --always).Trim()
$name = "ziti-deps-$sdkVersion-$Arch-windows"
$stage = Join-Path ([IO.Path]::GetTempPath()) "$name-stage\$name"
$installed = "$Build/vcpkg_installed/$triplet"

Remove-Item -Recurse -Force (Split-Path $stage) -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$stage/include", "$stage/lib/cmake/ziti-deps", $Out | Out-Null
$headers = "$installed/include",
    "$Build/_deps/ziti-sdk-c-src/includes",
    "$Build/_deps/tlsuv-src/include",
    "$Build/_deps/tlsuv-build/generated",
    "$Build/_deps/tlsuv-src/deps/uv_link_t/include"
foreach ($dir in $headers) { Copy-Item -Recurse -Force "$dir/*" "$stage/include/" }

foreach ($lib in 'stc', 'libuv', 'libssl', 'libcrypto', 'libsodium', 'json-c', 'protobuf-c', 'llhttp', 'zlib') {
    Copy-Item "$installed/lib/$lib.lib" "$stage/lib/"
}
Copy-Item "$Build/_deps/ziti-sdk-c-build/library/ziti.lib", "$Build/_deps/tlsuv-build/tlsuv.lib" "$stage/lib/"
Copy-Item "$repo/cmake/ziti-deps-config.cmake" "$stage/lib/cmake/ziti-deps/"

$zip = Join-Path (Resolve-Path $Out) "$name.zip"
Remove-Item $zip -ErrorAction SilentlyContinue
Compress-Archive -Path $stage -DestinationPath $zip
$zip
