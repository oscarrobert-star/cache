
---

# Project README

This project sets up a production-ready infrastructure on Google Cloud Platform (GCP) for a Flask application with integrated Pub/Sub messaging, Cloud SQL, Cloud Run, and more. The infrastructure is provisioned using Terraform, and the application is deployed using Docker.

## Infrastructure Overview

This infrastructure is provisioned and managed using **Terraform**, and it includes the following key components:

1. **VPC (Virtual Private Cloud)**: 
   - A private network is created to ensure the isolation of resources.
   
2. **Cloud SQL (PostgreSQL)**:
   - A managed PostgreSQL database is set up using Cloud SQL.
   
3. **Pub/Sub**:
   - A Google Cloud Pub/Sub topic is set up to handle asynchronous messaging.
   
4. **Secrets Management**:
   - Sensitive data like database credentials are stored in **Google Secret Manager**.
   
5. **IAM (Identity and Access Management)**:
   - A service account is created for Cloud Run to securely interact with GCP resources.

6. **Cloud Run**:
   - The Flask app is containerized using Docker and deployed to Google Cloud Run, ensuring auto-scaling and serverless deployment.

7. **Artifact Registry**:
   - The Docker images for the application are stored in Google Artifact Registry.

## Modules Used

- **VPC**: Creates a private VPC with subnets.
- **Cloud SQL**: Creates a PostgreSQL database in Google Cloud SQL.
- **Pub/Sub**: Creates a Pub/Sub topic for messaging.
- **Secrets**: Manages the storage of sensitive data (e.g., DB credentials) using Google Secret Manager.
- **IAM**: Configures necessary permissions and service accounts for the application.
- **Cloud Run**: Deploys the application to Google Cloud Run, connecting it to the Cloud SQL and Pub/Sub resources.

## Prerequisites

- **Terraform**: To provision the infrastructure.
- **Google Cloud Account**: Access to Google Cloud with permissions to create resources.
- **Docker**: For building and pushing the application container image.
- **Google Cloud SDK**: For interacting with GCP services.
- **Python**: Flask app dependencies for the backend.
- **Enable GCP Apis**: Enable all required APIs to successfully provision the infrastructure.

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/oscarrobert-star/cache.git
cd cache/terraform/environments/staging
```

### 2. Configure Terraform Variables

Ensure that the following variables are set in your `terraform.tfvars` or environment:

```bash
project = "your-gcp-project-id"
db_password = "your-secure-db-password"
region = "<your-region>"
image = "your-image-resource-name"
environment = "staging" # or "production"
```

### 3. Initialize Terraform

Run the following command to initialize the Terraform working directory:

```bash
terraform init
```

### 4. GCP Login and Configuration

Login to your GCP environment on the terminal and enable all the necessary APIs.

```bash
gcloud auth login
gcloud config set project your-gcp-project-id
```

Enable the following APIs using CLI or on the GCP console:

```
Cloud Resource Manager API
Service Networking API
Serverless VPC Access API
Cloud Run API
Cloud Pub/Sub API
Cloud SQL Admin API
IAM API
Secret Manager API
Artifact Registry API
Compute Engine API
Cloud Logging API
Cloud Monitoring API
```

#### Enable APIs using gcloud CLI

```bash
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  servicenetworking.googleapis.com \
  vpcaccess.googleapis.com \
  run.googleapis.com \
  pubsub.googleapis.com \
  sqladmin.googleapis.com \
  iam.googleapis.com \
  secretmanager.googleapis.com \
  artifactregistry.googleapis.com \
  compute.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com
```

### 5. Plan and Apply Terraform Configuration
> To apply this successfully, you need to first build the application image and update the image url in you tfvars file.

Apply the Terraform configuration to create the resources in Google Cloud:

```bash
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

This will provision the following resources:
- VPC
- Cloud SQL (PostgreSQL)
- Pub/Sub
- Secret Manager (for storing DB credentials)
- IAM Service Account for Cloud Run
- Cloud Run Service
- Artifact Registry (for storing Docker images)


### 6. Application Configuration and Deployment

1. **Dockerfile**: Ensure the `Dockerfile` exists in the root of your Flask app. Example:

```Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "main.py"]
```

2. **Build and Push the Docker Image**:

   Build and push the Docker image to Artifact Registry.

```bash
docker build -t <your-region>-docker.pkg.dev/your-gcp-project-id/staging-app-repo/app:latest .
docker push <your-region>-docker.pkg.dev/your-gcp-project-id/staging-app-repo/app:latest
```

### 7. Deploy to Cloud Run

Once the image is built and pushed to the Artifact Registry, deploy the application to Cloud Run:

```bash
gcloud run services update staging-app \
  --image <your-region>-docker.pkg.dev/your-gcp-project-id/staging-app-repo/app:latest \
  --platform managed \
  --region <your-region>
```

### 8. Access the Flask App

Once deployed, the application will be available at the URL provided by Cloud Run. You can check the status of your service in the Cloud Console.

## Application Routes

The Flask app exposes the following routes:

- **`/health`**:
  - **GET**: Checks if the application and database are reachable.
  - Returns `{ "status": "ok" }` if healthy, or `{ "status": "db unreachable" }` if the database is down.

- **`/publish`**:
  - **POST**: Publishes a message to the Pub/Sub topic. Expects a JSON payload with the `message` field.

  Example request body:

  ```json
  {
    "message": "Hello, Pub/Sub!"
  }
  ```

- **`/ingest`**:
  - **POST**: Pulls messages from the Pub/Sub subscription and inserts them into the PostgreSQL database. Returns the inserted IDs.

- **`/fetch`**:
  - **GET**: Fetches messages from the Pub/Sub subscription and returns them as a JSON response.

### 9. **CI/CD Workflow with GitHub Actions**

A GitHub Actions workflow is used to automate the process of building and deploying the application to **Google Cloud Run** whenever changes are pushed to the `main` branch. This ensures consistent and reliable deployments with minimal manual intervention.

#### 9.1 **Workflow Overview**

The workflow is triggered by a `push` to the `main` branch. It performs the following actions:

1. **Check out the repository**
2. **Set up Docker and Buildx**
3. **Configure the Google Cloud CLI**
4. **Authenticate Docker with Artifact Registry**
5. **Build the Docker image**
6. **Push the image to Google Artifact Registry**
7. **Deploy the updated image to Cloud Run**

#### 9.2 **Workflow File**

```yaml
name: Build and Deploy to Cloud Run

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    env:
      REGION: ${{ secrets.GCP_REGION }}
      COMMIT: ${{ github.sha }}

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up Google Cloud Authentication
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Set up Google Cloud CLI
        uses: google-github-actions/setup-gcloud@v1
        with:
          version: 'latest'
          project_id: ${{ secrets.GCP_PROJECT_ID }}

      - name: Authenticate Docker to Google Cloud
        run: gcloud auth configure-docker $REGION-docker.pkg.dev --quiet

      - name: Build Docker image
        run: |
          IMAGE_TAG="$REGION-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/staging-app-repo/app:$COMMIT"
          docker build -t $IMAGE_TAG -f app/Dockerfile app/

      - name: Push Docker image to Google Container Registry
        run: |
          IMAGE_TAG="$REGION-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/staging-app-repo/app:$COMMIT"
          docker push $IMAGE_TAG

      - name: Deploy to Google Cloud Run
        run: |
          IMAGE_TAG="$REGION-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/staging-app-repo/app:$COMMIT"
          gcloud run services update staging-app --image $IMAGE_TAG --platform managed --region $REGION
```

#### 9.3 **Secrets Used**

The workflow requires several GitHub secrets to be set:

- `GCP_REGION`: The Google Cloud region where the Cloud Run service is deployed (e.g., `us-central1`).
- `GCP_PROJECT_ID`: The Google Cloud project ID.
- `GCP_CREDENTIALS`: A JSON key for a service account with permissions to deploy to Cloud Run and access Artifact Registry.

#### 9.4 **Security Considerations**

- The service account used in `GCP_CREDENTIALS` should follow the principle of least privilege.
- Secrets must be stored in GitHub’s encrypted secrets manager.
- Ensure access to GitHub Actions is restricted to authorized personnel.

## 10 Managing Logs with Cloud Logging

####  **Centralized Logging & Auditability**

The application integrates with **Google Cloud Logging** (formerly Stackdriver) for comprehensive, centralized log management across all services.

#### Key Benefits:
1. **Centralized Log Management**: Application and infrastructure logs — including those from Cloud Run, GCP services, and the Flask app — are automatically forwarded to Cloud Logging, making them easily queryable and filterable via the Google Cloud Console.
2. **Auditability**: **Cloud Audit Logs** are enabled by default, capturing critical actions such as IAM role changes, API requests, and system-level operations, ensuring full traceability.
3. **Simplified Setup**: Logging is automatically activated during infrastructure provisioning. Enabling the **Cloud Logging API** as part of the Terraform setup ensures no manual configuration is required. [See section on enabling Google Cloud service APIs](#enable-apis-using-gcloud-cli)
4. **Monitoring & Alerting**: Logs can be used to create monitoring dashboards and alert policies, supporting observability and operational readiness.
5. **ELK Stack Alternative**: Cloud Logging eliminates the overhead of managing a self-hosted logging stack while still offering rich features for log ingestion, visualization, and retention.

All logs can be searched, visualized, and analyzed directly in **Cloud Logging Explorer**, supporting efficient debugging and real-time insight into system behavior.


## Cleanup

To destroy the infrastructure, run:

```bash
terraform destroy
```

This will remove all the resources created by Terraform.

