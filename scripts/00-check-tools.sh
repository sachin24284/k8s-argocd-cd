#!/usr/bin/env bash
# Verifies the tools used in this lab are installed and that docker-desktop Kubernetes is reachable.
for t in git docker kubectl; do
  command -v "$t" >/dev/null && echo "ok      $t: $($t version --client 2>/dev/null | head -1 || $t --version)" || echo "MISSING $t"
done
for t in go helm argocd; do
  command -v "$t" >/dev/null && echo "ok      $t (optional)" || echo "absent  $t (optional)"
done
echo "--- docker"; docker info --format 'CPUs={{.NCPU}} Memory={{.MemTotal}} bytes' 2>/dev/null || echo "Docker not running"
echo "--- kubernetes"; kubectl --context docker-desktop get nodes 2>/dev/null || echo "docker-desktop Kubernetes not reachable (enable it in Docker Desktop settings)"
