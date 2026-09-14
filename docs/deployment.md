# Deployment

## Local Deployment

The application can be run locally using FastAPI and Uvicorn.

```bash
uvicorn main:app --reload


The API is available at:
http://localhost:8000



Docker Deployment
The application can also be packaged and run as a Docker container.
Build the image:
docker build -t task-management-api .

Run the container:
docker run -d -p 8000:8000 --name task-api task-management-api

The application is then available at:
http://localhost:8000


```markdown
# AWS Networking

## Planned Architecture
The application will eventually be deployed to AWS.
The planned infrastructure will use:
- VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- Route Tables
- Security Groups

The infrastructure will later be provisioned using Terraform.

## Network Design
The public subnet will be used for components that need controlled
internet access.

Application workloads will be placed in private network segments
where possible.

This design will be implemented and documented in the Terraform phase.