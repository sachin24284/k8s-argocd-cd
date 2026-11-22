#!/usr/bin/env bash
# Usage: scripts/03-build-app-image.sh 1.0.0
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="${1:-1.0.0}"
docker build --build-arg VERSION="$VERSION" -t "hello-web:${VERSION}" app-src/hello-web
