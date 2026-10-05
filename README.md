# Cloud-Native DevOps Platform

A hands-on DevOps portfolio project demonstrating how to build, containerize, provision, deploy, secure, monitor, and continuously deliver a containerized application on Microsoft Azure using Terraform, Kubernetes, GitHub Actions, GitHub Container Registry, Trivy, Prometheus, and Grafana.

The project was intentionally built as a learning and portfolio environment rather than a production system. The infrastructure and implementation decisions documented here reflect what was actually built and tested.

---

## 1. Project Overview

This project deploys a small FastAPI Task Management API to Azure Kubernetes Service (AKS).

The complete workflow is:

```text
Developer
   │
   │ git push
   ▼
GitHub Repository
   │
   ▼
GitHub Actions
   │
   ├── Build Docker image
   ├── Build amd64 + arm64
   ├── Trivy security scan
   ├── Push image to GHCR
   ├── Authenticate to Azure using OIDC
   ├── Connect to AKS
   ├── Apply Kubernetes manifests
   └── Verify rollout
   │
   ▼
Azure AKS
   │
   ├── Task Management API
   ├── Kubernetes Service
   └── ServiceMonitor
   │
   ▼
Prometheus
   │
   ▼
Grafana
```

The infrastructure itself is managed using Terraform.

---

# 2. Project Goals

The main goals of this project were to gain practical experience with:

* Docker containerization
* Multi-platform container images
* Kubernetes deployments
* Kubernetes Services
* Replica scaling
* Kubernetes self-healing
* Azure Kubernetes Service
* Terraform infrastructure as code
* Azure networking
* Azure managed identities
* Azure RBAC
* GitHub Actions
* GitHub OIDC authentication
* GitHub Container Registry
* Trivy container security scanning
* Prometheus
* Prometheus Operator
* ServiceMonitor
* Grafana
* Cloud troubleshooting
* CI/CD automation

The project also served as a practical way to learn Azure because my previous cloud experience was primarily focused on AWS and Google Cloud.

---

# 3. Technology Stack

| Technology                | Purpose                                     |
| ------------------------- | ------------------------------------------- |
| Python                    | Application language                        |
| FastAPI                   | REST API framework                          |
| Docker                    | Containerization                            |
| GitHub Container Registry | Private container image registry            |
| Kubernetes                | Container orchestration                     |
| Azure AKS                 | Managed Kubernetes platform                 |
| Terraform                 | Infrastructure as Code                      |
| GitHub Actions            | CI/CD                                       |
| Trivy                     | Container vulnerability scanning            |
| Azure OIDC                | Passwordless GitHub-to-Azure authentication |
| Azure Managed Identity    | Azure workload identity                     |
| Azure RBAC                | Authorization                               |
| Prometheus                | Metrics collection                          |
| Prometheus Operator       | Kubernetes monitoring management            |
| ServiceMonitor            | Kubernetes monitoring configuration         |
| Grafana                   | Metrics visualization                       |
| Helm                      | Kubernetes package management               |

---

# 4. Application

The application is a simple Task Management API built with FastAPI.

It intentionally has a small scope because the purpose of this project is to demonstrate the infrastructure and DevOps lifecycle rather than application development.

## API endpoints

```text
GET  /
GET  /health
GET  /tasks
POST /tasks
GET  /metrics
```

The application stores tasks in an in-memory list.

Therefore:

> The application does not currently use a persistent database.

If the pod is recreated, application state stored only in memory is lost.

This is intentional for the scope of the portfolio project.

---

# 5. Application Container

The application is packaged using Docker.

The Docker image is based on:

```text
python:3.12-slim
```

The application listens on:

```text
Port 8000
```

Uvicorn is used as the application server.

The image is published to:

```text
ghcr.io/valinfernanda/task-management-api
```

---

# 6. Repository Structure

The repository contains the application, infrastructure, Kubernetes manifests, and CI/CD configuration.

A simplified structure is:

```text
cloud-native-devops-platform/
│
├── app/
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── kubernetes/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── servicemonitor.yaml
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
└── README.md
```

---

# 7. Azure Infrastructure

The Azure infrastructure is provisioned using Terraform.

The main resources include:

* Azure Resource Group
* Azure Virtual Network
* AKS subnet
* AKS cluster
* AKS node pool
* User-assigned managed identities
* Azure role assignments
* GitHub Actions federated identity credential

Current Azure region:

```text
East US
```

---

# 8. Current Azure Architecture

The current infrastructure is:

```text
Azure
│
└── Resource Group
    │
    ├── Virtual Network
    │   ├── Address space: 10.0.0.0/16
    │   │
    │   └── AKS Subnet
    │       └── 10.0.1.0/24
    │
    ├── AKS Cluster
    │   │
    │   └── System Node Pool
    │       └── 1 node
    │
    ├── AKS Managed Identity
    │
    └── GitHub Actions Managed Identity
```

The Kubernetes service network is separate:

```text
VNet:
10.0.0.0/16

AKS subnet:
10.0.1.0/24

Kubernetes service CIDR:
10.2.0.0/16

Kubernetes DNS service IP:
10.2.0.10
```

The service CIDR was deliberately chosen so it does not overlap with the VNet address space.

---

# 9. Terraform

Terraform is used to provision and manage the Azure infrastructure.

This means the infrastructure configuration is stored as code rather than being created manually through the Azure Portal.

Typical workflow:

```bash
terraform init
terraform plan
terraform apply
```

Terraform manages resources such as:

* Resource Group
* Virtual Network
* Subnet
* AKS
* AKS node pool
* Managed identities
* Role assignments
* Federated identity credential

This makes the environment reproducible.

---

# 10. AKS Configuration

The current AKS cluster uses:

```text
Region: East US
Kubernetes: 1.35.x
Node count: 1
Node pool: system
VM size: Standard_D2as_v7
Network plugin: Azure
```

The cluster uses a user-assigned managed identity.

The current environment is intentionally small to keep resource usage and cost under control.

---

# 11. Important Distinction: Pods vs Nodes

One of the most important lessons from this project was understanding the difference between:

### Kubernetes pods

Pods run the application.

Current:

```text
2 application replicas
```

### AKS nodes

Nodes are the virtual machines that run Kubernetes workloads.

Current:

```text
1 AKS node
```

These are different levels of scaling.

```text
AKS Cluster
│
└── Node
    │
    ├── Pod
    └── Pod
```

---

# 12. Application Replica Scaling

During the earlier Central US environment, I tested Kubernetes application scaling.

The application was initially configured with:

```yaml
replicas: 2
```

I manually scaled it to three replicas:

```bash
kubectl scale deployment task-management-api --replicas=3
```

The test successfully produced three running application pods.

After the test, the application was returned to the intended configuration of:

```text
2 replicas
```

Therefore:

> **Application replica scaling from 2 → 3 was successfully tested historically in the Central US cluster.**

It should not be interpreted as the current number of replicas.

### Current state

```text
Application replicas: 2
AKS nodes: 1
```

---

# 13. Kubernetes Self-Healing

Kubernetes self-healing was also tested.

The test involved deleting an application pod:

```bash
kubectl delete pod <pod-name>
```

Kubernetes detected that the Deployment no longer had the desired number of replicas and created a replacement pod.

This demonstrated the basic Kubernetes reconciliation model:

```text
Desired state:
2 replicas

        ↓

One pod deleted

        ↓

Actual state:
1 replica

        ↓

Kubernetes reconciliation

        ↓

Replacement pod created

        ↓

Actual state:
2 replicas
```

This is one of the key benefits of using a Kubernetes Deployment.

---

# 14. Important Limitation of the Scaling Test

The historical three-pod test occurred while the cluster had only one AKS node.

Therefore, the three application pods were not demonstrating multi-node workload distribution.

The test demonstrated:

* Kubernetes replica scaling
* Deployment reconciliation
* Pod self-healing

It did **not** demonstrate:

* multi-node high availability
* pod distribution across multiple nodes
* node failure recovery

This distinction is important because the project is intentionally honest about what was actually tested.

---

# 15. AKS Node Scaling Attempt

I also attempted to scale the AKS node pool from:

```text
1 node → 3 nodes
```

Terraform correctly detected the desired change.

However, Azure rejected the operation because of the regional vCPU quota.

The Central US environment had:

```text
Total Regional vCPUs:
Current: 4
Limit:   4
```

The VM family quota was also exhausted:

```text
Standard Bpsv2 Family:
Current: 4
Limit:   4
```

The AKS operation returned an error similar to:

```text
ErrCode_InsufficientVCPUQuota
```

The requested scaling operation could not obtain enough regional compute capacity.

---

# 16. Why Node Scaling Failed

AKS node pool operations may require additional temporary capacity during an upgrade or scaling operation.

The cluster was already at the available regional vCPU limit.

Therefore, even though the Terraform configuration requested:

```text
node_count = 3
```

Azure could not provision the required additional capacity.

This was not a Kubernetes configuration failure.

It was an Azure quota limitation.

---

# 17. Central US → East US Migration

Instead of requesting a quota increase for the learning environment, I decided to move the infrastructure to another Azure region.

The original environment was:

```text
Central US
```

The new environment was recreated in:

```text
East US
```

Terraform was used to recreate the infrastructure rather than manually rebuilding the environment through the Azure Portal.

The migration was therefore also a practical Terraform exercise.

---

# 18. Why the Region Was Changed

The main reason for the migration was the exhausted Central US compute quota.

The decision was:

```text
Central US
   │
   └── vCPU quota exhausted
          │
          ├── Request quota increase
          │
          └── Move region
                  ↓
               East US
```

For this portfolio project, moving regions was simpler than requesting a quota increase.

---

# 19. Terraform Upgrade Settings Troubleshooting

While working on the AKS node pool configuration, I also experimented with upgrade settings.

An attempted `max_unavailable` configuration was rejected by the AzureRM provider configuration being used.

The final configuration uses:

```hcl
upgrade_settings {
  max_surge = "10%"
}
```

This was another example of adjusting the Terraform configuration based on the actual provider/API behavior rather than assuming that every AKS setting would work identically in the chosen provider version.

---

# 20. Docker Multi-Platform Image

An image architecture compatibility issue was encountered during the project.

The Docker image was therefore changed to build for multiple architectures:

```text
linux/amd64
linux/arm64
```

GitHub Actions uses Docker Buildx for this.

The workflow publishes both architectures to GHCR.

This improves compatibility between the container image and different Kubernetes node architectures.

---

# 21. GitHub Container Registry

The application image is stored in GitHub Container Registry:

```text
ghcr.io/valinfernanda/task-management-api
```

The repository is private, so the AKS cluster requires authentication when pulling the image.

This created an important distinction between two different authentication flows.

---

# 22. GHCR Push vs AKS Pull Authentication

There are two separate operations:

### GitHub Actions → GHCR

GitHub Actions uses:

```text
GITHUB_TOKEN
```

with:

```yaml
permissions:
  packages: write
```

This allows the workflow to push the container image.

### AKS → GHCR

AKS uses a Kubernetes image pull secret:

```text
ghcr-secret
```

The secret allows Kubernetes to authenticate to GHCR when pulling the private image.

Therefore:

```text
GitHub Actions
      │
      │ GITHUB_TOKEN
      ▼
     GHCR
      ▲
      │
      │ ghcr-secret
      │
     AKS
```

These are separate authentication mechanisms.

---

# 23. GHCR Secret Problem After Cluster Migration

When the cluster was recreated in East US, the old Kubernetes resources did not automatically exist in the new cluster.

This included:

```text
ghcr-secret
```

The deployment therefore failed because AKS could not authenticate to the private GHCR image.

The Kubernetes events showed errors such as:

```text
FailedToRetrieveImagePullSecret
```

and:

```text
401 Unauthorized
```

The issue was not with the Docker image itself.

The new Kubernetes cluster simply did not have the required image pull secret.

---

# 24. Fixing the GHCR Pull Secret

A GitHub token with package read permission was created for the Kubernetes image pull operation.

The secret was then created in Kubernetes using:

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password=<github-token>
```

The actual token is intentionally not documented or committed to the repository.

After the secret was recreated, Kubernetes successfully pulled the private image and the application pods returned to:

```text
Running
```

---

# 25. Security Scanning with Trivy

The CI/CD pipeline scans the container image using Trivy.

The workflow checks:

```text
CRITICAL
HIGH
```

severity vulnerabilities.

The configuration also uses:

```text
ignore-unfixed: true
```

The pipeline is configured to fail when matching vulnerabilities are found:

```text
exit-code: 1
```

This prevents the pipeline from silently continuing when serious known vulnerabilities are detected.

---

# 26. GitHub Actions CI/CD

The project uses GitHub Actions to automate the deployment process.

The workflow runs when code is pushed to:

```text
main
```

The high-level pipeline is:

```text
Git push
   ↓
Checkout
   ↓
Login to GHCR
   ↓
Docker Buildx
   ↓
Build amd64 + arm64
   ↓
Trivy scan
   ↓
Push image to GHCR
   ↓
Azure OIDC login
   ↓
Set AKS context
   ↓
kubectl apply
   ↓
Rollout verification
```

The pipeline is currently running successfully end-to-end.

---

# 27. GitHub Actions Workflow

The workflow contains these major stages:

### 1. Checkout

```yaml
uses: actions/checkout@v4
```

### 2. Authenticate to GHCR

```yaml
uses: docker/login-action@v3
```

### 3. Configure Buildx

```yaml
uses: docker/setup-buildx-action@v3
```

### 4. Build and push

The image is built for:

```text
linux/amd64
linux/arm64
```

and pushed to GHCR.

Both a commit SHA tag and `latest` are published.

### 5. Trivy scan

The built image is scanned for HIGH and CRITICAL vulnerabilities.

### 6. Azure login

The workflow authenticates to Azure using OIDC.

### 7. AKS context

The workflow obtains the Kubernetes context for the AKS cluster.

### 8. Deployment

The Kubernetes manifests are applied:

```bash
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/servicemonitor.yaml
```

### 9. Verification

The workflow verifies:

```bash
kubectl rollout status deployment/task-management-api
kubectl get pods
kubectl get service task-management-api
```

---

# 28. Azure OIDC Authentication

GitHub Actions does not use a long-lived Azure password or client secret.

Instead, the workflow uses:

```text
GitHub OIDC
```

The flow is:

```text
GitHub Actions
      │
      │ OIDC token
      ▼
Microsoft Entra ID
      │
      │ Federated identity trust
      ▼
Azure Managed Identity
      │
      │ RBAC permissions
      ▼
AKS
```

This reduces the need to store long-lived Azure credentials in GitHub Secrets.

---

# 29. Federated Identity Credential

Azure was configured with a federated identity credential that trusts the GitHub Actions identity.

The trust is based on claims from GitHub's OIDC token, including:

* issuer
* audience
* repository/workflow context

The important concept is:

> The federated identity credential establishes **who GitHub is allowed to authenticate as**.

It does not by itself grant access to AKS resources.

---

# 30. Azure RBAC

Authorization is handled separately through Azure RBAC.

The GitHub Actions identity was assigned an AKS role allowing the workflow to obtain the required Kubernetes access.

This illustrates an important distinction:

```text
OIDC / Federated Identity
        =
Authentication / Trust

Azure RBAC
        =
Authorization / Permissions
```

---

# 31. Azure OIDC Troubleshooting

The first GitHub Actions Azure login attempt failed.

Azure returned:

```text
AADSTS700213
```

The problem was a mismatch between the GitHub OIDC subject presented by the workflow and the subject configured in Azure's federated identity credential.

The initial subject assumption did not exactly match the actual assertion.

The federated identity credential was corrected to match the actual GitHub OIDC claim.

After the correction, Terraform successfully updated the federated credential and the GitHub Actions Azure login succeeded.

This was a useful practical lesson:

> OIDC federation requires an exact match of the relevant identity claims. A small subject mismatch is enough to cause authentication failure.

---

# 32. Managed Identities

Two different user-assigned managed identities are used for different purposes.

## AKS identity

The AKS managed identity is used by the AKS infrastructure for Azure resource access.

For example, the identity has the required network permissions.

## GitHub Actions identity

A separate user-assigned identity is used for GitHub Actions.

It is trusted through the GitHub OIDC federated credential and receives the required AKS RBAC permissions.

Separating these identities follows the principle of least privilege more closely than using one identity for everything.

---

# 33. Azure Networking

The AKS environment uses an Azure VNet.

Current design:

```text
VNet
10.0.0.0/16
│
└── AKS subnet
    10.0.1.0/24
```

The Kubernetes service network is:

```text
10.2.0.0/16
```

The Kubernetes DNS service uses:

```text
10.2.0.10
```

The networks were configured without overlapping CIDR ranges.

---

# 34. Kubernetes Deployment

The application is deployed through a Kubernetes Deployment.

Conceptually:

```text
Deployment
    │
    ├── Replica 1
    │
    └── Replica 2
```

The Deployment ensures that the desired number of application replicas are maintained.

Current desired state:

```yaml
replicas: 2
```

---

# 35. Kubernetes Service

The application is exposed using a Kubernetes `LoadBalancer` Service.

The service maps:

```text
Port 80
   ↓
Container port 8000
```

Conceptually:

```text
Internet
   │
   ▼
Azure Load Balancer
   │
   ▼
Kubernetes Service
   │
   ├── Pod
   └── Pod
```

This allows external traffic to reach the FastAPI application.

---

# 36. Private Image Pulling

Because the GHCR image is private, the Deployment references:

```text
ghcr-secret
```

The relevant Kubernetes concept is:

```yaml
imagePullSecrets:
  - name: ghcr-secret
```

The secret is kept outside the repository.

---

# 37. Monitoring Architecture

Monitoring is implemented using:

```text
kube-prometheus-stack
```

This provides:

* Prometheus
* Prometheus Operator
* Grafana
* Alertmanager
* kube-state-metrics
* node exporter
* Kubernetes monitoring resources

The stack runs in:

```text
monitoring
```

namespace.

---

# 38. ServiceMonitor

The application exposes:

```text
/metrics
```

for Prometheus.

A Kubernetes `ServiceMonitor` is used to tell the Prometheus Operator how to discover and scrape the application.

The relationship is:

```text
FastAPI
   │
   │ /metrics
   ▼
Kubernetes Service
   │
   ▼
ServiceMonitor
   │
   ▼
Prometheus Operator
   │
   ▼
Prometheus
```

A ServiceMonitor is not Prometheus itself.

It is a Kubernetes custom resource that describes what should be monitored.

---

# 39. ServiceMonitor Configuration

The application ServiceMonitor:

```text
Name:
task-management-api

Namespace:
default
```

It selects the application Service using the appropriate application labels.

The metrics endpoint is:

```text
/metrics
```

with a scrape interval of:

```text
15 seconds
```

---

# 40. ServiceMonitor CRD Problem

After recreating the cluster in East US, applying the ServiceMonitor initially failed because the ServiceMonitor Custom Resource Definition was not installed.

The error indicated that Kubernetes did not recognize:

```text
monitoring.coreos.com/v1
```

or:

```text
ServiceMonitor
```

The reason was that ServiceMonitor is not a built-in Kubernetes resource.

It is provided by the Prometheus Operator.

---

# 41. Fixing the Monitoring CRD

The `kube-prometheus-stack` Helm chart was installed into the monitoring namespace.

This installed the required Prometheus Operator components and CRDs.

The ServiceMonitor resource could then be created successfully.

The cluster now contains the expected ServiceMonitor resources.

---

# 42. Prometheus Verification

The Prometheus targets were checked after the monitoring stack was installed.

The application target:

```text
task-management-api
```

was confirmed as:

```text
UP
```

This verifies that Prometheus is successfully scraping the application's metrics endpoint.

This is stronger evidence than simply checking whether the Prometheus pod is running.

---

# 43. Grafana

Grafana is deployed as part of the `kube-prometheus-stack`.

The Grafana pod is running successfully.

However, the previous Grafana dashboard from the original Central US environment did not migrate automatically to the new East US cluster.

The historical Grafana dashboard and data were therefore not treated as part of the current environment.

The current project confirms that:

* Grafana is deployed
* Prometheus is running
* the application is being scraped successfully

A fully rebuilt application dashboard is not currently claimed as part of the East US implementation.

This is intentional and keeps the README accurate.

---

# 44. Monitoring Flow

The complete monitoring flow is:

```text
FastAPI Application
        │
        │ exposes /metrics
        ▼
Kubernetes Service
        │
        ▼
ServiceMonitor
        │
        ▼
Prometheus Operator
        │
        ▼
Prometheus
        │
        ▼
Grafana
```

---

# 45. End-to-End CI/CD Flow

The complete application delivery flow is:

```text
Developer
   │
   │ git push
   ▼
GitHub
   │
   ▼
GitHub Actions
   │
   ├── Checkout
   │
   ├── Build Docker image
   │
   ├── Build amd64 + arm64
   │
   ├── Trivy security scan
   │
   ├── Push to GHCR
   │
   ├── Authenticate to Azure using OIDC
   │
   ├── Obtain AKS context
   │
   ├── Apply Kubernetes manifests
   │
   └── Verify rollout
   │
   ▼
AKS
   │
   ├── Deployment
   ├── Pods
   ├── Service
   └── ServiceMonitor
   │
   ▼
Prometheus
   │
   ▼
Grafana
```

---

# 46. Problems Encountered and Solutions

One of the main purposes of this project was to learn from real infrastructure problems rather than only following a successful tutorial.

## Problem 1 — Azure vCPU quota

### Symptom

AKS node scaling from 1 → 3 failed.

### Cause

Central US had exhausted regional vCPU quota.

### Solution

The environment was migrated from Central US to East US using Terraform.

### Lesson

Cloud resource limits can affect infrastructure operations even when the Terraform configuration itself is valid.

---

## Problem 2 — AKS node scaling vs application scaling

### Symptom

The project successfully scaled application replicas but node scaling failed.

### Cause

These are two different layers.

### Result

```text
Application replicas:
2 → 3
SUCCESS during historical test

AKS nodes:
1 → 3
BLOCKED by Azure quota
```

### Lesson

Kubernetes workload scaling and underlying infrastructure scaling are separate concepts.

---

## Problem 3 — Terraform AKS upgrade configuration

### Symptom

An attempted `max_unavailable` configuration was rejected by the provider configuration.

### Solution

The configuration was simplified to use:

```hcl
max_surge = "10%"
```

### Lesson

Terraform provider versions and Azure API capabilities need to be considered when configuring managed resources.

---

## Problem 4 — GitHub OIDC authentication

### Symptom

GitHub Actions failed to authenticate to Azure with:

```text
AADSTS700213
```

### Cause

The federated identity subject did not exactly match the GitHub OIDC assertion.

### Solution

The federated identity credential was corrected to match the actual GitHub OIDC subject.

### Lesson

Federated identity matching is exact; small claim differences can cause authentication failure.

---

## Problem 5 — Missing GHCR image pull secret

### Symptom

AKS returned:

```text
401 Unauthorized
```

and:

```text
FailedToRetrieveImagePullSecret
```

### Cause

The new cluster did not contain the old cluster's `ghcr-secret`.

### Solution

The Kubernetes image pull secret was recreated.

### Lesson

Kubernetes Secrets are cluster resources and are not automatically recreated when a cluster is rebuilt.

---

## Problem 6 — Missing ServiceMonitor CRD

### Symptom

The ServiceMonitor manifest could not be applied.

### Cause

The new cluster did not yet have the Prometheus Operator CRD.

### Solution

Installed `kube-prometheus-stack` using Helm.

### Lesson

Custom Kubernetes resources depend on their corresponding CRDs being installed first.

---

## Problem 7 — Container architecture compatibility

### Symptom

A container image architecture compatibility problem was encountered.

### Solution

The CI/CD pipeline was changed to build:

```text
linux/amd64
linux/arm64
```

### Lesson

Container architecture needs to be considered when deploying images to cloud infrastructure.

---

## Problem 8 — Terraform Resource Group deletion

At one point Terraform attempted to delete the Resource Group while resources were still present.

Azure/Terraform prevented the deletion rather than silently removing resources that remained inside the group.

The remaining resources had to be handled before the Resource Group could be removed cleanly.

### Lesson

Terraform's resource lifecycle protections can prevent accidental destructive operations.

---

# 47. Central US vs East US

The migration can be summarized as follows:

| Item                 | Original Environment            | Current Environment      |
| -------------------- | ------------------------------- | ------------------------ |
| Region               | Central US                      | East US                  |
| AKS                  | Yes                             | Yes                      |
| Node count           | 1                               | 1                        |
| Application replicas | Tested 2 → 3                    | 2                        |
| Node scaling 1 → 3   | Attempted                       | Not claimed as completed |
| Main issue           | vCPU quota                      | Working                  |
| Terraform            | Yes                             | Yes                      |
| GitHub Actions       | Yes                             | Yes                      |
| OIDC                 | Troubleshooting required        | Working                  |
| GHCR                 | Working after secret recreation | Working                  |
| Prometheus           | Installed                       | Installed                |
| ServiceMonitor       | Installed                       | Installed                |
| Grafana              | Installed                       | Installed                |

---

# 48. Current Project State

The current East US environment is working with:

```text
Azure AKS
    │
    └── 1 node
          │
          ├── task-management-api pod
          └── task-management-api pod
```

The application currently runs:

```text
2 replicas
```

The CI/CD pipeline is green.

The image is built for:

```text
amd64
arm64
```

Trivy scanning is enabled.

GHCR image publishing works.

GitHub Actions authenticates to Azure using OIDC.

Kubernetes deployment works.

The application exposes metrics.

Prometheus successfully reports the application target as:

```text
UP
```

Grafana is deployed as part of the monitoring stack.

---

# 49. What Was Successfully Demonstrated

This project successfully demonstrated:

* FastAPI application containerization
* Docker image creation
* Multi-platform Docker builds
* Private GHCR image publishing
* Kubernetes Deployment
* Kubernetes Service
* Application replica scaling
* Kubernetes self-healing
* AKS deployment
* Azure networking
* Terraform infrastructure provisioning
* Azure managed identities
* Azure RBAC
* GitHub OIDC authentication
* GitHub Actions CI/CD
* Trivy container scanning
* Prometheus installation
* Prometheus Operator
* ServiceMonitor
* Successful Prometheus scraping
* Grafana deployment
* Real-world cloud troubleshooting
* Infrastructure recreation after a region migration

---

# 50. What Was NOT Implemented

To keep the project scope realistic, the following are not currently implemented as production-grade features:

* Multi-node AKS high availability
* Horizontal Pod Autoscaler (HPA)
* Cluster autoscaler
* Persistent database
* Stateful workloads
* Kubernetes Ingress
* TLS/HTTPS configuration
* Azure Key Vault integration
* Network Policies
* Production-grade secret management
* Advanced Grafana application dashboards in the new cluster
* Production alerting configuration
* Disaster recovery
* Multi-region deployment
* Blue/green deployment
* Canary deployment

These are potential future improvements rather than features that should be claimed as already implemented.

---

# 51. Future Improvements

Possible future improvements include:

## Kubernetes

* Configure HPA based on CPU/memory or application metrics
* Test multi-node scheduling
* Add pod anti-affinity
* Add resource requests and limits
* Add readiness and liveness probes
* Add PodDisruptionBudget

## Networking

* Add Ingress
* Configure HTTPS/TLS
* Add Network Policies
* Improve network security

## Security

* Replace manually managed registry credentials with a more secure workload identity approach where practical
* Integrate Azure Key Vault
* Improve secret management
* Add additional container security controls
* Add dependency scanning

## Observability

* Rebuild the application Grafana dashboard
* Add alerts
* Add application-specific SLO/SLI metrics
* Add centralized logging
* Add distributed tracing

## Application

* Add a persistent database
* Add authentication
* Add proper task persistence
* Add automated tests

## Infrastructure

* Add separate dev/staging/prod environments
* Add Terraform remote state
* Add CI validation for Terraform
* Add Terraform security scanning
* Add automated infrastructure deployment
* Add autoscaling

---

# 52. Lessons Learned

## 1. Cloud limits are part of infrastructure engineering

A valid Terraform configuration does not guarantee that Azure can provision the requested resources.

Quota, capacity, region availability, and VM family limits all matter.

---

## 2. Kubernetes scaling has multiple layers

Scaling application replicas is different from scaling infrastructure nodes.

```text
Pod scaling:
2 → 3 replicas

Node scaling:
1 → 3 VMs
```

The first was successfully tested.

The second was blocked by Azure quota.

---

## 3. Kubernetes is declarative

When a pod was manually deleted, Kubernetes recreated it because the Deployment continuously reconciles the actual state with the desired state.

---

## 4. Cluster recreation means cluster-scoped resources need to be recreated

The new East US cluster did not automatically contain:

* Kubernetes Secrets
* Prometheus CRDs
* monitoring configuration
* old Grafana state

This highlighted the importance of treating cluster configuration as reproducible infrastructure.

---

## 5. Authentication and authorization are different

GitHub OIDC establishes identity trust.

Azure RBAC determines what that identity is allowed to do.

Understanding this distinction was an important part of implementing the CI/CD pipeline.

---

## 6. Monitoring has multiple components

Prometheus, Prometheus Operator, ServiceMonitor, and Grafana serve different purposes.

```text
ServiceMonitor
      ↓
Prometheus Operator
      ↓
Prometheus
      ↓
Grafana
```

---

## 7. Troubleshooting is part of DevOps

The project was not built without failures.

The actual development process included:

* Azure quota errors
* Terraform configuration issues
* OIDC authentication failures
* missing Kubernetes Secrets
* missing CRDs
* container architecture compatibility problems
* infrastructure migration

Resolving these issues was an important part of the learning experience.

---

# 53. Interview Talking Points

This project can be explained in an interview as follows:

### "What did you build?"

> I built a small cloud-native Task Management API using FastAPI and deployed it to Azure Kubernetes Service. I provisioned the Azure infrastructure with Terraform and created a GitHub Actions CI/CD pipeline that builds a multi-platform Docker image, scans it with Trivy, pushes it to GHCR, authenticates to Azure using OIDC, and deploys the application to AKS.

### "What Kubernetes features did you use?"

> I used Deployments, Services, replicas, image pull secrets, and a ServiceMonitor. I tested application replica scaling from two to three replicas and also tested Kubernetes self-healing by deleting a pod and observing Kubernetes recreate it.

### "Did you scale the AKS nodes?"

> I attempted to scale the AKS node pool from one to three nodes, but Azure blocked the operation because the Central US regional vCPU quota was already exhausted. Instead of requesting a quota increase for this learning environment, I recreated the infrastructure in East US using Terraform.

### "Why did you move regions?"

> The original Central US environment had reached its regional vCPU quota. Since the project was a development environment, moving to East US was more practical than requesting a quota increase.

### "How does GitHub Actions authenticate to Azure?"

> I used GitHub OIDC with a federated identity credential in Microsoft Entra ID. GitHub obtains an OIDC token, Azure validates the federated identity, and the corresponding managed identity receives permissions through Azure RBAC.

### "How does AKS pull your private image?"

> GitHub Actions uses the GitHub token to push the image to GHCR. AKS uses a Kubernetes image pull secret containing registry credentials to pull the private image.

### "How did you monitor the application?"

> The FastAPI application exposes a Prometheus `/metrics` endpoint. I created a ServiceMonitor, installed kube-prometheus-stack, and verified that Prometheus reports the application target as UP. Grafana is also deployed as part of the monitoring stack.

### "Did you use Terraform?"

> Yes. I used Terraform to provision the Azure Resource Group, VNet, subnet, AKS cluster, identities, role assignments, and GitHub federated identity configuration.

---

# 54. Project Evidence

Important evidence from the project includes:

### Infrastructure

```text
Terraform-managed Azure infrastructure
```

### Kubernetes

```text
Deployment
Service
2 application replicas
Self-healing test
```

### Containerization

```text
Docker
linux/amd64
linux/arm64
GHCR
```

### Security

```text
Trivy
GitHub OIDC
Azure RBAC
Private image authentication
```

### CI/CD

```text
GitHub Actions
Build
Scan
Push
Authenticate
Deploy
Verify
```

### Monitoring

```text
Prometheus
ServiceMonitor
Prometheus target: UP
Grafana
```

---

# 55. Final Architecture

```text
                         GitHub
                           │
                           │ git push
                           ▼
                  ┌──────────────────┐
                  │ GitHub Actions   │
                  └────────┬─────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
           Docker        Trivy        GHCR
           Build         Scan       Image Registry
              │                         │
              │                         │
              └────────────┬────────────┘
                           │
                           │ OIDC
                           ▼
                    Microsoft Entra ID
                           │
                           │ RBAC
                           ▼
                    Azure AKS Cluster
                           │
                    ┌──────┴──────┐
                    │             │
                    ▼             ▼
                  Pod           Pod
             FastAPI API    FastAPI API
                    │             │
                    └──────┬──────┘
                           │
                           ▼
                    Kubernetes Service
                           │
                           ▼
                      Application
                       /metrics
                           │
                           ▼
                     ServiceMonitor
                           │
                           ▼
                       Prometheus
                           │
                           ▼
                        Grafana


Terraform
    │
    ├── Resource Group
    ├── VNet
    ├── Subnet
    ├── AKS
    ├── Managed Identity
    ├── RBAC
    └── GitHub Federated Identity
```

---

# 56. Final Summary

This project demonstrates a complete cloud-native DevOps workflow from source code to a running Kubernetes workload.

The infrastructure is provisioned with Terraform, the application is containerized with Docker, images are scanned with Trivy and stored in GHCR, and GitHub Actions automates deployment to Azure AKS using OIDC authentication.

Kubernetes provides application deployment, service exposure, replica management, and self-healing. Prometheus and ServiceMonitor provide application metrics collection, while Grafana is deployed as part of the monitoring stack.

A significant part of the project was also troubleshooting real infrastructure problems. The original Central US environment reached its Azure vCPU quota when I attempted to scale the AKS node pool from one to three nodes. I therefore recreated the environment in East US using Terraform.

The project deliberately distinguishes between what was successfully tested and what remains future work:

```text
Application scaling 2 → 3:
SUCCESS — historical Central US test

Pod self-healing:
SUCCESS

AKS node scaling 1 → 3:
ATTEMPTED — blocked by Azure quota

Current AKS nodes:
1

Current application replicas:
2

GitHub Actions:
SUCCESS

Docker multi-platform build:
SUCCESS

Trivy:
ENABLED

GHCR:
WORKING

Azure OIDC:
WORKING

Prometheus scraping:
WORKING — target UP

Grafana:
DEPLOYED

Production-grade HA:
NOT IMPLEMENTED
```

The primary value of this project is therefore not simply that an application runs on AKS, but that it demonstrates the practical DevOps lifecycle of building, provisioning, securing, deploying, monitoring, troubleshooting, and documenting a cloud-native workload.
