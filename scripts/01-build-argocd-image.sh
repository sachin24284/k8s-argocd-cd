#!/usr/bin/env bash
# Builds Argo CD from the source zip into a local Docker image (takes 10-30 min first time).
set -euo pipefail
cd "$(dirname "$0")/.."
SRC="${ARGOCD_SRC:-./argo-cd-master}"
TAG="${ARGOCD_TAG:-3.7.0-local}"
docker build -t "argocd-custom:${TAG}" "$SRC"
docker images argocd-custom
