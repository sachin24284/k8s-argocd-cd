#!/usr/bin/env bash
# Rebuild Argo CD from your modified source and roll it out to docker-desktop.
# Usage: scripts/05-dev-loop.sh <new-tag>      e.g. 3.7.0-local2
set -euo pipefail
cd "$(dirname "$0")/.."
NEW_TAG="${1:?usage: $0 <new-tag>}"
SRC="${ARGOCD_SRC:-./argo-cd-master}"
docker build -t "argocd-custom:${NEW_TAG}" "$SRC"
sed -i.bak "s/newTag: .*/newTag: ${NEW_TAG}/" platform/argocd-install/kustomization.yaml && rm -f platform/argocd-install/kustomization.yaml.bak
kubectl config use-context docker-desktop
kubectl apply -n argocd --server-side --force-conflicts -k platform/argocd-install
kubectl -n argocd rollout restart deployment argocd-server argocd-repo-server argocd-applicationset-controller argocd-notifications-controller
kubectl -n argocd rollout restart statefulset argocd-application-controller
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s
