#!/usr/bin/env bash
# Usage: scripts/04-set-repo-url.sh <your-github-username>
set -euo pipefail
cd "$(dirname "$0")/.."
USER_NAME="${1:?usage: $0 <github-username>}"
grep -rl YOUR_GITHUB_USER gitops-repo | while read -r f; do
  sed -i.bak "s/YOUR_GITHUB_USER/${USER_NAME}/g" "$f" && rm -f "$f.bak"
done
echo "Repo URL set to https://github.com/${USER_NAME}/argocd-lab-gitops.git"
