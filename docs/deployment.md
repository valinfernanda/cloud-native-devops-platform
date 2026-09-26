Deployment

This document describes how the Task Management API is run locally, containerized with Docker, deployed to Azure Kubernetes Service (AKS), and monitored with Prometheus and Grafana.

1. Local Deployment

The application is built with FastAPI and can be run locally using Uvicorn.

uvicorn main:app --reload

The API is available at:

http://localhost:8000
Health Check
GET /health

Example response:

{
  "status": "healthy"
}
Application Metrics

Prometheus metrics are exposed through:

GET /metrics

These metrics are used by Prometheus for application monitoring.

2. Docker Deployment

The application is packaged as a Docker image using the app/Dockerfile.

Build the Image
docker build -t task-management-api ./app
Run the Container
docker run -d \
  -p 8000:8000 \
  --name task-api \
  task-management-api

The API is then available at:

http://localhost:8000
3. Kubernetes Deployment

The application is deployed to Azure Kubernetes Service (AKS).

The Kubernetes configuration consists of:

k8s/deployment.yaml — application Deployment
k8s/service.yaml — LoadBalancer Service
k8s/servicemonitor.yaml — Prometheus ServiceMonitor
Application Deployment

Apply the Kubernetes Deployment:

kubectl apply -f k8s/deployment.yaml

The application runs with two replicas to provide basic availability within the cluster.

Verify the pods:

kubectl get pods
Kubernetes Service

Apply the Service:

kubectl apply -f k8s/service.yaml

The Service exposes the application through an Azure LoadBalancer.

Verify the Service:

kubectl get service task-management-api
4. CI/CD

The project uses GitHub Actions to automate the application build and deployment process.

The CI/CD workflow:

Builds the Docker image.
Pushes the image to GitHub Container Registry (GHCR).
Authenticates to Azure using GitHub Actions OIDC.
Connects to the AKS cluster.
Applies the Kubernetes manifests.
Verifies the deployment rollout and running pods.

The container image is published to:

ghcr.io/valinfernanda/task-management-api

This allows application changes pushed to the repository to be built and deployed through the automated pipeline.

5. Monitoring

Application and Kubernetes monitoring is implemented using Prometheus and Grafana.

The monitoring architecture is:

                    ┌─────────────────┐
                    │    FastAPI      │
                    │                 │
                    │    /metrics     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Kubernetes      │
                    │ Service         │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ ServiceMonitor  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Prometheus    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    Grafana      │
                    └─────────────────┘
Prometheus Metrics

The FastAPI application uses Prometheus instrumentation and exposes metrics through:

/metrics

The Kubernetes ServiceMonitor discovers the application Service and configures Prometheus to scrape the metrics endpoint every 15 seconds.

Apply the ServiceMonitor:

kubectl apply -f k8s/servicemonitor.yaml

Verify the ServiceMonitor:

kubectl get servicemonitor

Prometheus target health can be verified through the Prometheus Targets page.

Grafana Dashboard

The Grafana dashboard provides visibility into both infrastructure and application-level metrics.

Infrastructure metrics:

AKS Node CPU Usage
AKS Node Memory Usage
Total Kubernetes Pods
AKS Node Status

Application metrics:

API Request Rate
Total API Requests
API Response Time (p95)
API 5xx Error Rate
API Availability

This provides visibility from the Kubernetes infrastructure layer through to application behavior.

6. Deployment Architecture

The overall deployment flow is:

Developer
    │
    │ git push
    ▼
GitHub
    │
    ▼
GitHub Actions
    │
    ├── Build Docker Image
    │
    ├── Push Image
    │      │
    │      ▼
    │     GHCR
    │
    └── Deploy
           │
           ▼
         Azure
           │
           ▼
          AKS
           │
           ├── FastAPI Pods
           │
           └── Kubernetes Service
                    │
                    ▼
              ServiceMonitor
                    │
                    ▼
                Prometheus
                    │
                    ▼
                 Grafana

The infrastructure supporting the AKS environment is provisioned using Terraform, while the application deployment is managed through Kubernetes manifests and the GitHub Actions CI/CD pipeline.