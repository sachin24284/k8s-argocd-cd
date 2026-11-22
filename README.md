# argocd-lab - hands-on GitOps with Argo CD on Docker Desktop Kubernetes

Open this folder in VS Code (File > Open Folder). Accept the "install recommended extensions" prompt.
Then follow docs/LAB-GUIDE.md phase by phase. Run scripts from the integrated terminal
(Windows: use a WSL terminal) or via Terminal > Run Task.

  argo-cd-master/      <- your Argo CD source (unzip argo-cd-slim.zip or the full zip here)
  platform/            <- how Argo CD itself is installed (Kustomize + local image + RBAC patches)
  app-src/hello-web/   <- demo app + GitHub Actions workflow (becomes its own GitHub repo "hello-web")
  gitops-repo/         <- becomes the GitHub repo "argocd-lab-gitops" (Argo CD watches it)
  scripts/             <- 00 check, 01 build, 02 install, 03 app image, 04 repo url, 05 dev loop, 06 UI, 99 cleanup
  .vscode/             <- recommended extensions, tasks
