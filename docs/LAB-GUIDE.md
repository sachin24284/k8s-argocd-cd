# LAB GUIDE - every phase has: goal, steps, and a check that proves it worked

Placeholders: <user> = your GitHub username. Everything runs on Docker Desktop Kubernetes (context `docker-desktop`).

## Phase 0 - Tools and VS Code
Install: Docker Desktop (10+ GB RAM, Kubernetes enabled, kubeadm mode), Git, kubectl, VS Code.
Optional: Go (version in argo-cd-master/go.mod), Helm, argocd CLI. Windows: install WSL2 and use VS Code "WSL" extension.
Run `./scripts/00-check-tools.sh`.   CHECK: docker-desktop node shows Ready.

## Phase 1 - Git and GitHub (two repos)
Create two EMPTY public GitHub repos: `argocd-lab-gitops` and `hello-web`.
- gitops-repo/  -> argocd-lab-gitops      - app-src/hello-web/ -> hello-web
Learn: commit, push, branches, pull requests. Rule for GitOps: Git is the only way you change the cluster.

## Phase 2 - Docker: build Argo CD from source
Put the Argo CD source in ./argo-cd-master. Run `./scripts/01-build-argocd-image.sh` (10-30 min first time).
CHECK: `docker images argocd-custom`. Learn: multi-stage builds (UI stage, Go stage, final image), why one binary has many symlinks.

## Phase 3 - Kubernetes basics (explore before installing)
kubectl get nodes / ns / pods -A ; kubectl describe node docker-desktop ; kubectl api-resources | head
Learn: namespaces, pods, deployments, services, CRDs.

## Phase 4 - Install Argo CD (Kustomize)
`./scripts/02-install-argocd.sh`    then   `./scripts/06-port-forward.sh`  (UI https://localhost:8080)
CHECK: last lines of the script list `argocd-custom:3.7.0-local`; you can log in as admin.
Learn: Kustomize `images:` and `patches:` (see platform/argocd-install), server-side apply, StatefulSet vs Deployment.
Then change the admin password and delete the initial secret:
  argocd login localhost:8080 --username admin --insecure
  argocd account update-password
  kubectl -n argocd delete secret argocd-initial-admin-secret

## Phase 5 - First GitOps apps (app-of-apps + ApplicationSet + Kustomize overlays)
./scripts/03-build-app-image.sh 1.0.0
./scripts/04-set-repo-url.sh <user>
cd gitops-repo && git init -b main && git add . && git commit -m initial
git remote add origin https://github.com/<user>/argocd-lab-gitops.git && git push -u origin main && cd ..
kubectl apply -f gitops-repo/bootstrap/root-app.yaml
CHECK: `kubectl get applications -n argocd` shows root, hello-web-dev, hello-web-prod, hello-helm, hooks-demo, podinfo.
(If `podinfo` fails to resolve `6.*`, open its page in the UI, check the chart versions, and set an exact targetRevision.)
Learn: Application, AppProject, ApplicationSet (list generator), Kustomize base/overlays.

## Phase 6 - The GitOps loop (experiments)
1. Drift:   kubectl -n hello-prod scale deploy hello-web --replicas=5   -> self-heal reverts to 2.
2. Git change: edit replicas in overlays/prod, commit, push -> Refresh in UI.
3. Prune: delete a file in base/, push -> the resource disappears.
4. Rollback: argocd app set hello-web-dev --sync-policy none ; argocd app history hello-web-dev ; argocd app rollback hello-web-dev <id>
5. Break it on purpose (bad YAML) and read the error under APP CONDITIONS in the UI.
Source to read afterwards: controller/appcontroller.go -> autoSync().

## Phase 7 - Helm
- Local chart: `hello-helm` Application deploys gitops-repo/charts/hello-helm with `valuesObject` replicaCount=2.
  CHECK: kubectl -n hello-helm get pods (2 pods). Change replicaCount in argocd-config/apps.yaml, push, watch.
- Public chart: `podinfo` Application installs a chart straight from a Helm repository.
  CHECK: kubectl -n podinfo port-forward svc/podinfo 9898:9898 -> http://localhost:9898
Learn: Chart.yaml, values, templates, difference between a Git path and a chart repo as a source.

## Phase 8 - Sync waves and hooks
The `hooks-demo` app is manual-sync on purpose. In the UI click SYNC.
Order you should see: PreSync Job db-migrate -> wave 0 ConfigMap -> wave 1 Deployment -> PostSync Job smoke-test.
Experiment: change the Deployment wave to "-1" and re-sync; make the PreSync job `exit 1` and watch the sync fail (SyncFail hook).
Source: gitops-engine/pkg/sync/sync_context.go, docs/user-guide/sync-waves.md, resource_hooks.md.

## Phase 9 - Projects, RBAC, accounts
AppProject `lab` limits repos, namespaces and cluster resources. Try: add a destination namespace not in the list -> sync is denied.
A local read-only user `devuser` already exists (platform/argocd-install/patches):
  argocd account update-password --account devuser --new-password <pwd> --current-password <admin pwd>
  argocd login localhost:8080 --username devuser --insecure   -> can view, cannot sync.
Learn: argocd-cm accounts, argocd-rbac-cm policy.csv, built-in roles.

## Phase 10 - CI/CD with GitHub Actions + GHCR
Push app-src/hello-web to the `hello-web` repo (it contains .github/workflows/build-push-bump.yaml).
Create a token with write access to argocd-lab-gitops and save it as secret GITOPS_PAT in the hello-web repo.
Push a change to index.html -> workflow builds ghcr.io/<user>/hello-web:<sha>, commits the new tag to the dev overlay.
After the first run, make the GHCR package public (GitHub > Packages > hello-web > settings).
CHECK: hello-web-dev syncs by itself and the page shows the new version. Flow: code -> CI image -> Git commit -> Argo CD deploy.

## Phase 11 - Observability and CLI
kubectl -n argocd logs sts/argocd-application-controller --tail=50
kubectl -n argocd port-forward svc/argocd-metrics 8082:8082    -> http://localhost:8082/metrics  (argocd_app_info ...)
kubectl -n argocd port-forward svc/argocd-server-metrics 8083:8083
argocd app list ; argocd app get hello-web-dev ; argocd app diff hello-web-dev ; argocd app manifests hello-web-dev
Learn: Prometheus-style metrics, health vs sync status, reading controller logs.

## Phase 12 - Notifications (optional, needs internet)
Edit platform/optional/notifications-webhook.yaml (free URL from webhook.site) and apply it as written in the file's header.
CHECK: sync an app and see the JSON arrive on webhook.site.

## Phase 13 - Change Argo CD itself (Go developer loop in VS Code)
1. Install Go (see go.mod) and the VS Code Go extension. Run a small test:  cd argo-cd-master && go test ./common/...
2. Open controller/appcontroller.go, find func (ctrl *ApplicationController) autoSync, and add this line right after
   `logCtx := log.WithFields(applog.GetAppLogFields(app))` :
       logCtx.Infof("LAB: autoSync evaluated, sync status = %s", syncStatus.Status)
3. ./scripts/05-dev-loop.sh 3.7.0-local2
4. kubectl -n argocd logs sts/argocd-application-controller | grep LAB      -> your line appears. You changed Argo CD.
Next ideas: read docs/developer-guide/debugging-locally.md to debug a component with a VS Code launch config.

## Phase 14 - Cleanup and troubleshooting
./scripts/99-cleanup.sh resets everything. Common errors:
  ImagePullBackOff (argocd) -> check `docker images argocd-custom`, use kubeadm mode.   ImagePullBackOff (hello-web) -> build the tag first.
  Out of memory in build -> raise Docker Desktop memory.   App Unknown -> repo must be public, branch `main` pushed.

## Skills and tools covered
Git/GitHub, VS Code, Docker (multi-stage), Kubernetes (kubectl, CRDs), Kustomize, Helm, Argo CD (apps, projects, appsets,
hooks, waves, RBAC, notifications, metrics), GitHub Actions, GHCR, GitOps CI/CD, Go build/test, reading a large OSS codebase.
Not covered here (good next steps): Terraform for AKS, Sealed Secrets/External Secrets, Ingress + TLS, Argo Rollouts, multi-cluster.
