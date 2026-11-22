#!/usr/bin/env bash
# Installs Argo CD (your local image) into the docker-desktop Kubernetes cluster.
set -euo pipefail
cd "$(dirname "$0")/.."
SRC="${ARGOCD_SRC:-./argo-cd-master}"
kubectl config use-context docker-desktop
# Upstream manifests use imagePullPolicy: Always, which would try to pull our local image from the internet.
sed 's/imagePullPolicy: Always/imagePullPolicy: IfNotPresent/' "$SRC/manifests/install.yaml" > platform/argocd-install/install.yaml
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -k platform/argocd-install
kubectl -n argocd wait --for=condition=available deployment --all --timeout=300s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s
echo "Images in use:"
kubectl get pods -n argocd -o jsonpath='{..image}' | tr ' ' '\n' | sort -u
