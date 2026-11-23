# Kubernetes Continuous Delivery Using Argo CD (GitOps)

![Argo CD](https://img.shields.io/badge/Argo%20CD-3.7.0-EF7B4D?logo=argo&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Docker%20Desktop-326CE5?logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-multi--stage%20builds-2496ED?logo=docker&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-charts-0F1689?logo=helm&logoColor=white)
![Kustomize](https://img.shields.io/badge/Kustomize-overlays-326CE5)
![GitOps](https://img.shields.io/badge/GitOps-Git%20as%20source%20of%20truth-success)

A hands-on **GitOps** project: I built **Argo CD v3.7.0 from source**, deployed it on a local **Kubernetes** cluster, and used it to deploy applications automatically from this Git repository. Every change goes through Git, and Argo CD keeps the cluster matching it.

- **Built Argo CD from source** into a Docker image with a multi-stage build (Node.js UI + Go binaries), then installed that custom image on Kubernetes.
- **Declarative installs with Kustomize:** swapped the image, fixed the image pull policy, and patched config maps (local user and RBAC) without editing upstream manifests.
- **App-of-apps pattern:** one `root` Application creates the AppProject and ApplicationSet from Git.
- **ApplicationSet:** one template generates the **dev** and **prod** applications automatically.
- **Environment overlays with Kustomize:** dev runs 1 replica, prod runs 2, from the same base manifests.
- **Helm:** deploys a local chart and a public chart from a Helm repository.
- **Deployment control:** PreSync and PostSync **hooks** and **sync waves** for ordered rollouts.
- **Self-healing and drift detection:** manual cluster changes are reverted automatically to match Git.
- **Least privilege:** an AppProject limits allowed repositories and namespaces, and a read-only user is configured through RBAC.
- **Troubleshooting:** solved real environment issues (WSL2, Docker Desktop, image pull policy, repo access) during setup.

## How it works

![Workflow](docs/images/workflow.svg)

1. **Push:** I edit YAML in VS Code and push to GitHub.
2. **Read:** Argo CD's repo server reads the repo and renders the manifests (Kustomize or Helm).
3. **Apply:** the application controller compares Git with the cluster and syncs the difference.
4. **Report:** live state is reported back, and drift is reverted when self-heal is on.
5. **Images:** the Argo CD image and the demo app image are built locally with Docker and run in the cluster.
6. **Observe:** the Argo CD web UI (`localhost:8080`) and `kubectl` show status, history and health.

## Tools and technologies

| Category | Tools | Used for |
|---|---|---|
| GitOps / CD | **Argo CD 3.7.0** | Continuous delivery, sync, self-heal, UI |
| Containers | **Docker**, Docker Desktop, WSL2 | Building and running images |
| Orchestration | **Kubernetes** (Docker Desktop cluster), `kubectl` | Running the workloads |
| Config management | **Kustomize**, **Helm** | Overlays for dev/prod, charts |
| Source control | **Git**, **GitHub**, GitHub Desktop | Single source of truth |
| Languages | **Go** (Argo CD), TypeScript/React (Argo CD
