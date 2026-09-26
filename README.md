# Cloud-Native DevOps Platform

An end-to-end DevOps portfolio project that demonstrates how to build, containerize, deploy, automate, and monitor a cloud-native application.

The project uses **Azure, Terraform, Docker, Kubernetes, GitHub Actions, GitHub Container Registry, Prometheus, and Grafana** to create a complete application deployment workflow.

---

## What I Built

I built a containerized **Task Management REST API** with FastAPI and deployed it to **Azure Kubernetes Service (AKS)**.

The infrastructure is provisioned with **Terraform**, application deployments are automated through **GitHub Actions**, container images are stored in **GitHub Container Registry (GHCR)**, and the application is monitored with **Prometheus and Grafana**.

The project demonstrates the complete flow from infrastructure provisioning to application deployment and monitoring.

---

## Architecture

```text
                         Developer
                            │
                         git push
                            │
                            ▼
                     ┌─────────────┐
                     │   GitHub    │
                     └──────┬──────┘
                            │
                            ▼
                    ┌────────────────┐
                    │ GitHub Actions │
                    └───────┬────────┘
                            │
                 ┌──────────┴──────────┐
                 │                     │
                 ▼                     ▼
          ┌──────────────┐      ┌──────────────┐
          │     GHCR     │      │    Azure     │
          │ Docker Image │      │     AKS      │
          └──────┬───────┘      └──────┬───────┘
                 │                     │
                 └──────────┐  ┌───────┘
                            ▼  ▼
                      ┌──────────────┐
                      │ Kubernetes   │
                      │ Application  │
                      └──────┬───────┘
                             │
                          /metrics
                             │
                             ▼
                      ┌──────────────┐
                      │  Prometheus  │
                      └──────┬───────┘
                             │
                             ▼
                      ┌──────────────┐
                      │   Grafana    │
                      └──────────────┘
```

---

## Application

The application is a simple **Task Management REST API** built with:

* Python
* FastAPI
* Uvicorn
* Pydantic

### Current Endpoints

| Method | Endpoint   | Purpose            |
| ------ | ---------- | ------------------ |
| GET    | `/`        | API status         |
| GET    | `/health`  | Health check       |
| GET    | `/tasks`   | Retrieve tasks     |
| POST   | `/tasks`   | Create a task      |
| GET    | `/metrics` | Prometheus metrics |

The application currently uses **in-memory storage** for tasks. The main purpose of the application is to provide a simple workload for demonstrating DevOps, cloud, Kubernetes, CI/CD, and monitoring practices.

---

## Cloud Infrastructure

The cloud infrastructure is provisioned using **Terraform** on Microsoft Azure.

The environment includes:

* Azure Resource Group
* Azure Virtual Network
* AKS subnet
* Azure Kubernetes Service (AKS)
* User-assigned Managed Identity
* Azure RBAC configuration

Terraform keeps the infrastructure configuration **version-controlled and reproducible** instead of requiring the environment to be created manually through the Azure Portal.

---

## Containerization

The application is packaged as a Docker image.

The image is published to **GitHub Container Registry (GHCR)**:

```text
ghcr.io/valinfernanda/task-management-api
```

Kubernetes pulls the image from GHCR when deploying the application.

---

## Kubernetes

The application runs on **Azure Kubernetes Service (AKS)**.

The Kubernetes configuration includes:

* Deployment
* Two application replicas
* LoadBalancer Service
* GHCR image pull secret
* ServiceMonitor for Prometheus

The application is deployed using Kubernetes manifests stored in the `kubernetes/` directory.

```text
kubernetes/
├── deployment.yaml
├── service.yaml
└── servicemonitor.yaml
```

The two application replicas provide basic redundancy within the Kubernetes cluster.

---

## CI/CD

The application deployment is automated using **GitHub Actions**.

When changes are pushed to the repository, the workflow:

1. Builds the Docker image.
2. Pushes the image to GHCR.
3. Authenticates to Azure using **GitHub Actions OIDC**.
4. Connects to the AKS cluster.
5. Applies the Kubernetes manifests.
6. Verifies the deployment and running pods.

This removes the need to manually build the image and deploy the application after every change.

---

## Authentication & Access Control

The CI/CD pipeline uses **OIDC authentication** to access Azure instead of storing a long-lived Azure password or service principal secret in GitHub.

The AKS environment also uses:

* Azure Managed Identity
* Azure RBAC

This demonstrates cloud-native identity and access management as part of the deployment architecture.

---

## Monitoring & Observability

The application exposes Prometheus metrics through:

```text
/metrics
```

The monitoring stack uses:

* Prometheus
* Grafana
* Prometheus FastAPI Instrumentator
* Kubernetes ServiceMonitor

The monitoring flow is:

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
Prometheus
   │
   ▼
Grafana
```

The `ServiceMonitor` configures Prometheus to scrape the application metrics every **15 seconds**.

### Grafana Dashboard

The Grafana dashboard provides visibility into both Kubernetes infrastructure and application behavior.

**Infrastructure metrics:**

* AKS Node CPU Usage
* AKS Node Memory Usage
* Total Kubernetes Pods
* AKS Node Status

**Application metrics:**

* API Request Rate
* Total API Requests
* API Response Time (p95)
* API 5xx Error Rate
* API Availability

This allows the project to be monitored from the Kubernetes infrastructure layer through to application-level performance.

---

## Project Structure

```text
cloud-native-devops-platform/
│
├── app/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
│
├── docs/
│   ├── architecture.png
│   └── deployment.md
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
├── README.md
└── .gitignore
```

---

## What Has Been Implemented

* [x] FastAPI REST API
* [x] Docker containerization
* [x] Azure infrastructure with Terraform
* [x] Azure Virtual Network
* [x] Azure Kubernetes Service (AKS)
* [x] Kubernetes Deployment
* [x] Two application replicas
* [x] Kubernetes LoadBalancer Service
* [x] GHCR container registry
* [x] GitHub Actions CI/CD
* [x] GitHub Actions OIDC authentication
* [x] Azure Managed Identity
* [x] Azure RBAC
* [x] Prometheus monitoring
* [x] Grafana dashboard
* [x] FastAPI application metrics
* [x] Kubernetes ServiceMonitor
* [x] Infrastructure monitoring
* [x] Application monitoring

---

## Documentation

More detailed documentation is available in the `docs/` directory.

* [Deployment](docs/deployment.md)
* [Architecture](docs/architecture.png)

---

## Project Purpose

This project was built as a practical DevOps portfolio project to demonstrate hands-on experience with:

* Cloud infrastructure
* Infrastructure as Code
* Docker and containerization
* Kubernetes
* CI/CD automation
* Cloud identity and access management
* Application deployment
* Monitoring and observability
* Troubleshooting and operational workflows
