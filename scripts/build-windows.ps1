# Builds libziti and its dependencies as static libraries with MSVC and vcpkg, then packages them into a zip.
# Usage: scripts/build-windows.ps1 -Out <output dir> -Work <scratch dir> [-Arch x64|arm64]
# Run from a shell with the MSVC toolchain on PATH (a Developer PowerShell, or the VsDevCmd the script loads).
param(
    [Parameter(Mandatory)] [string] $Out,
    [Parameter(Mandatory)] [string] $Work,
    [ValidateSet('x64', 'arm64')] [string] $Arch = 'x64'
)
$ErrorActionPreference = 'Stop'
$vcpkgCommit = 'c3867e714dd3a51c272826eea77267876517ed99'
$repo = Split-Path $PSScriptRoot -Parent
$triplet = "$Arch-windows-static"
$vcpkg = Join-Path $Work 'vcpkg'
$build = Join-Path $Work "build-$Arch"

if (-not (Get-Command cl -ErrorAction SilentlyContinue)) {
    $vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -property installationPath
    Import-Module "$vs\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
    Enter-VsDevShell -VsInstallPath $vs -SkipAutomaticLocation -DevCmdArguments "-arch=$($Arch) -host_arch=x64"
}

New-Item -ItemType Directory -Force $Work, $Out | Out-Null
if (-not (Test-Path $vcpkg)) {
    git clone https://github.com/microsoft/vcpkg $vcpkg
    git -C $vcpkg checkout $vcpkgCommit
}
if (-not (Test-Path "$vcpkg\vcpkg.exe")) { & "$vcpkg\bootstrap-vcpkg.bat" -disableMetrics }

$env:VCPKG_ROOT = $vcpkg
# vcpkg builds pkgconf as a host tool but does not put it on PATH; the dir exists once the manifest install runs.
$env:PATH = "$build\vcpkg_installed\x64-windows\tools\pkgconf;$env:PATH"
cmake -S $repo -B $build -G Ninja -DCMAKE_BUILD_TYPE=MinSizeRel `
    "-DCMAKE_TOOLCHAIN_FILE=$vcpkg/scripts/buildsystems/vcpkg.cmake" `
    "-DVCPKG_TARGET_TRIPLET=$triplet" -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded `
    "-DCMAKE_C_FLAGS=/Zc:preprocessor"
if ($LASTEXITCODE) { throw 'configure failed' }
cmake --build $build
if ($LASTEXITCODE) { throw 'build failed' }

& "$PSScriptRoot\package-windows.ps1" -Build $build -Out $Out -Arch $Arch
