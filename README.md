# Overview

This repository documents the implementation of a CI/CD pipeline for deploying an application on Kubernetes. It covers various tools and technologies, including Minikube, Docker, Helm, ArgoCD, and External Secrets, to facilitate smooth and automated deployment for both staging and production environments. This README also provides instructions for replicating the environment, promoting the application across environments, and updating Docker images during deployment.

## CI/CD Pipeline Structure and Functionality

The CI/CD pipeline automates the following stages:

1. **Build**: The application is built and a Docker image is created.
2. **Push:** The Docker image is pushed to a container registry (e.g., Docker Hub).
3. **Deploy:** The image is deployed to Kubernetes clusters using Helm charts.
4. **Promotion:** The deployment can be promoted between staging and production environments, ensuring a smooth transition from development to production.

### CI/CD Tools

- **Docker:** Used for creating containerized application images.
- **ArgoCD:** Used for continuous deployment by automatically synchronizing Kubernetes manifests (Helm charts) from a Git repository to the cluster.
- **Minikube:** A tool to run Kubernetes clusters locally for development and testing.
- **Helm:** Manages Kubernetes application deployments, configuration, and versioning.
- **External Secrets:** Manages sensitive information (e.g., database credentials) by retrieving them securely from external services like AWS Secrets Manager, HashiCorp Vault, etc.

## Helm Chart Usage and Configuration

### Helm Chart Structure

The Helm chart for deploying the application is located in the deploy/helm/charts/my-app directory. It is designed to be customizable for different environments (staging, production). The key components are:

**Chart.yaml:** Defines metadata about the chart (e.g., name, version).
**values.yaml:** Default configuration values used by the chart.
**templates/:** Contains Kubernetes manifest templates that define resources like Deployments, Services, and ConfigMaps.
**deployment.yaml:** A template that defines the deployment strategy and the application containers.
**values-production.yaml and values-staging.yaml:** Override files that specify environment-specific values, such as the image tag, database credentials, and other configurations.

### Helm Chart Configuration for Different Environments

- Production Configuration: The `values-production.yaml` file contains configurations for connecting to production database endpoints and other production-specific settings.
- Staging Configuration: The `values-staging.yaml` file contains configurations for staging environments. It may use a separate database or other infrastructure that is not intended for production.

### Deploying the Application

To deploy the application in either staging or production, use the following Helm commands:

```bash
# Deploy to staging
helm upgrade --install my-app ./deploy/helm/charts/my-app -f ./deploy/helm/charts/values-staging.yaml

# Deploy to production
helm upgrade --install my-app ./deploy/helm/charts/my-app -f ./deploy/helm/charts/values-production.yaml
```

These commands use the appropriate `values.yaml` files for each environment to ensure correct configurations for database connections and other settings.

## Kubernetes Cluster Setup and Deployment Steps

### Setting Up the Kubernetes Cluster

This application is designed to run on a Kubernetes cluster. You can set up a Minikube cluster locally for testing.

```bash
# Start Minikube cluster
minikube start

# Set Up kubectl: Make sure your kubectl is configured to interact with Minikube.
kubectl config use-context minikube

# Verify the Cluster: Ensure that the cluster is up and running by checking the node status:
kubectl get nodes
```

## Docker Image Push and Deployment

The Docker image of the application is built and pushed to a container registry (e.g., Docker Hub). The steps for pushing the image and updating the deployment are as follows:

```bash
# Build the Docker image
docker build -t <docker-username>/my-app:<tag> .

# Push the Docker image to the registry
docker push <docker-username>/my-app:<tag>
```

## Automating Image Tag Updates with ArgoCD

ArgoCD Image Updater can be configured to automatically update the image tag in the Kubernetes deployment based on the latest image pushed to the registry. This process eliminates manual intervention and speeds up deployment.

Advantages of an automated image updater:

- **Reduced Manual Work:** No need to manually update the image tag every time a new image is pushed.
- **Faster Releases:** Images are automatically pulled and deployed to the cluster, ensuring faster and more reliable releases.
- **Consistency:** Ensures that the correct image version is always used in deployments.

Tools for automating image updates:

- **ArgoCD Image Updater:** Automatically updates Kubernetes deployments based on the latest image tags.
- **FluxCD Image Automation:** A similar tool that works in a similar manner, automating the process of updating image tags in Kubernetes.

## Promotion Strategy for Environments (Staging → Production)

When promoting from staging to production, you can follow this process:

1. **Create Separate Branches:**

- `staging:` For staging environment deployments.
- `master:` For production environment deployments.

2. **Environment-Specific Values:**

- Use separate Helm values files (`values-staging.yaml` and `values-production.yaml`) to manage environment-specific configurations (e.g., database endpoints, API keys).

3. **ArgoCD Sync:** ArgoCD will handle synchronization between Git repositories and Kubernetes clusters. Once a commit is made to the `master` branch, ArgoCD can automatically trigger the promotion to production by updating the deployment with the corresponding values file (`values-production.yaml`).

## External Secrets Management

We use **External Secrets** to manage sensitive data such as database credentials. This allows Kubernetes to securely retrieve secrets from external secret management systems.

### Steps for Using External Secrets:

1. **Install the External Secrets Controller:** Use Helm to install the External Secrets controller on your Kubernetes cluster:

```bash
helm install external-secrets external-secrets/external-secrets
```

2. **Define an ExternalSecret Resource:** Define an ExternalSecret resource in Kubernetes

```bash
apiVersion: eksctl.io/v1alpha5
kind: ExternalSecret
metadata:
  name: mysql-secret
spec:
  backendType: secretsManager
  data:
    - key: "/path/to/secret"
      name: mysql-password
      property: password

```
