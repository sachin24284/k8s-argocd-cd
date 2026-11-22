#!/usr/bin/env bash
# Removes everything this lab created from docker-desktop Kubernetes.
cd "$(dirname "$0")/.."
kubectl config use-context docker-desktop
kubectl -n argocd delete applicationset --all --ignore-not-found
kubectl -n argocd delete applications --all --ignore-not-found
kubectl delete namespace hello-dev hello-prod hello-helm hooks-demo podinfo --ignore-not-found
kubectl delete -k platform/argocd-install --ignore-not-found
kubectl delete namespace argocd --ignore-not-found
