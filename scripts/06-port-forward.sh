#!/usr/bin/env bash
echo "Argo CD UI: https://localhost:8080   (user: admin)"
echo "Password:   $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d)"
kubectl port-forward svc/argocd-server -n argocd 8080:443
