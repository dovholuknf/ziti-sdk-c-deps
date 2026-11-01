#!/bin/sh
# Publishes the zips in a directory as a GitHub release.
# Usage: scripts/publish.sh <tag> <dir holding the zips>   (needs gh, authenticated)
set -eu

tag="$1"
dir="$2"
gh release create "$tag" "$dir"/*.zip --title "$tag" --notes "Static libziti and dependencies: musl (x64, arm64), macOS (arm64, x64), Windows (x64)."
