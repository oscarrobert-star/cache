
---

# Infrastructure Documentation

This document provides a comprehensive overview of the **Identity and Access Management (IAM)**, **Secrets Management**, and **Cloud Run** setup for the project. It ensures that the infrastructure meets security standards and aligns with best practices.

## 1. **Identity and Access Management (IAM)**

### 1.1 **Service Account for Cloud Run**

A dedicated service account is created for Cloud Run to securely interact with Google Cloud resources. The service account is configured with the minimal set of permissions necessary for the application to function.

#### IAM Configuration for Cloud Run Service Account:
```hcl
resource "google_service_account" "cloud_run_sa" {
  account_id   = var.service_account_name
  display_name = "Cloud Run Service Account for ${var.environment} environment"
  project      = var.project
}
```

### 1.2 **IAM Permissions for Cloud Run Service Account**

The Cloud Run service account is granted the necessary permissions to interact with Pub/Sub, Secret Manager, Cloud SQL, and Logging services.

#### Pub/Sub Publisher and Subscriber Access:
Cloud Run is configured to publish and subscribe to Pub/Sub topics, which are used for message handling.

```hcl
# Pub/Sub Publisher Access
resource "google_project_iam_member" "cloud_run_pubsub" {
  project = var.project
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Pub/Sub Subscriber Access
resource "google_project_iam_member" "cloud_run_pubsub_subscriber" {
  project = var.project
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}
```

#### Secret Manager Access:
Cloud Run is granted the `roles/secretmanager.secretAccessor` role to access secrets stored in Secret Manager.

```hcl
# Secret Manager Access
resource "google_project_iam_member" "cloud_run_secrets" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}
```

#### Cloud SQL Access:
Cloud Run is granted the `roles/cloudsql.client` role to access Cloud SQL databases.

```hcl
# Cloud SQL Access
resource "google_project_iam_member" "cloud_run_sql" {
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}
```

#### Logging Access:
Cloud Run is granted the `roles/logging.logWriter` role to write logs to Cloud Logging.

```hcl
# Logging Access
resource "google_project_iam_member" "cloud_run_logging" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}
```

### 1.3 **Role-Based Access Control (RBAC)**
- **Admin Role**: Full access to all resources.
- **App Role**: Access limited to Cloud Run, Cloud SQL, Pub/Sub, Secret Manager, and Logging.
- **Viewer Role**: Read-only access to logs and monitoring data.

## 2. **Secrets Management**

Sensitive data such as database credentials and API keys are stored securely using **Google Secret Manager**. This ensures that sensitive data is encrypted and can be accessed only by authorized services and users.

### 2.1 **Secret Manager Setup**
Secrets are created and managed in **Google Secret Manager**. The secrets are replicated across regions and can be accessed by authorized service accounts.

```hcl
resource "google_secret_manager_secret" "secret" {
  secret_id = var.name
  project   = var.project

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "version" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.value
}
```

### 2.2 **Access Control for Secrets**
The service account for Cloud Run is granted the `roles/secretmanager.secretAccessor` permission to access specific secrets stored in Secret Manager. Other service accounts are granted access only to the secrets they need, following the principle of least privilege.

### 2.3 **Encryption**
Secrets stored in Secret Manager are automatically encrypted using Google-managed encryption keys. All secrets are encrypted both at rest and in transit.

## 3. **Cloud Run Configuration**

Cloud Run is used to deploy and manage the application container. The configuration ensures secure access to Google Cloud services and environment-specific variables.

### 3.1 **Cloud Run Container Environment Variables**

The following environment variables are set in the Cloud Run service to manage application configurations securely:

```hcl
template {
  spec {
    containers {
      image = var.image

      env {
        name  = "ENV"
        value = var.environment
      }

      env {
        name  = "DB_SECRET_NAME"
        value = var.db_secret_name
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project
      }

      env {
        name  = "DB_HOST"
        value = var.db_host
      }

      env {
        name  = "PUBSUB_TOPIC"
        value = var.pubsub_topic
      }

      env {
        name  = "DB_NAME"
        value = var.db_name
      }

      env {
        name = "PUBSUB_SUBSCRIPTION"
        value = var.pubsub_subscription
      }
    }
    service_account_name = var.service_account_email
  }
}
```

These environment variables include configurations for:
- **Environment** (`ENV`): Defines the environment (e.g., production, staging).
- **Database Secret Name** (`DB_SECRET_NAME`): The name of the secret containing database credentials.
- **Project Name** (`GOOGLE_CLOUD_PROJECT`): The Google Cloud project name.
- **Database Host** (`DB_HOST`): The host URL for the database.
- **Pub/Sub Topic and Subscription** (`PUBSUB_TOPIC`, `PUBSUB_SUBSCRIPTION`): Configurations for the Pub/Sub topic and subscription.

### 3.2 **Service Account Configuration**

The Cloud Run service is assigned the appropriate service account that has the necessary IAM roles to interact with Google Cloud resources.

```hcl
service_account_name = var.service_account_email
```

This ensures that Cloud Run only has the necessary permissions and adheres to the principle of least privilege.

## 4. **Audit Logging**

Audit logs are critical for tracking activity and ensuring compliance with security standards.

### 4.1 **Cloud Audit Logs**
Google Cloud services automatically generate audit logs for the following categories:
- **Admin Activity Logs**: Track administrative actions such as resource creation, modification, or deletion.
- **Data Access Logs**: Track access to sensitive data, including reads and writes.

### 4.2 **Log Retention and Access**
- Logs are stored in **Cloud Logging** and are retained for 365 days by default.
- Access to logs is controlled via IAM roles. Only authorized users with `roles/logging.viewer` can view the logs, and users with `roles/logging.admin` can manage the logs.

### 4.3 **Log Monitoring and Alerts**
- Log-based metrics and alerts are set up to notify administrators of suspicious activities, such as unauthorized access attempts or failed service interactions.

## 5. **SOC 2 Alignment**

SOC 2 compliance is achieved by aligning the infrastructure with key security principles.

### 5.1 **Security**
- **IAM**: Access is granted based on the least privilege principle, with roles tightly controlling what resources can be accessed.
- **Secrets Management**: Sensitive data is encrypted and stored securely in **Google Secret Manager**.
- **Audit Logs**: All critical actions are logged using **Cloud Audit Logs** for auditing and monitoring purposes.
- **Encryption**: Data is encrypted both **at rest and in transit** using **Google-managed encryption keys** and **SSL Certificates**.
- **Version Control**: All infrastructure and application code is versioned using **Git**, allowing traceability and accountability for all changes.
- **Infrastructure as Code (IaC)**: The environment is provisioned and managed using **Terraform**, ensuring reproducibility, change control, and compliance with approved configurations.

### 5.2 **Availability**
- **Cloud Run**: Automatically scales based on traffic, ensuring high availability. The maximum number of instances is capped at 4 to manage cost and performance predictability.
- **Cloud SQL**: [⚠️] *Note: Automatic backups and failover are currently **not configured**. For SOC 2 alignment, it is recommended to enable these features to ensure database resilience and recovery capabilities.*

### 5.3 **Processing Integrity**
- **Cloud Pub/Sub**: Provides **reliable message delivery**, ensuring processing integrity in asynchronous workflows.
- **Database Transactions**: All critical database operations are **wrapped in transactions** to ensure data consistency and rollback on failure.
- **CI/CD Pipelines**: Code is deployed through **automated CI/CD workflows**, which enforce code reviews, testing, and deployment standards.

### 5.4 **Confidentiality**
- **Data Encryption**: All sensitive data is encrypted using **Google-managed encryption keys**.
- **Access Control**: Strict policies (e.g., **IAM roles**, **service accounts**) ensure that only authorized users and services can access sensitive data.
- **Environment Isolation**: Separate environments (e.g., dev, staging, production) are used to limit data exposure during testing.

### 5.5 **Privacy**
- **Data Minimization**: Only necessary data is collected and stored.
- **No PII Collected**: The application is designed to **avoid collection of Personally Identifiable Information (PII)**, reducing privacy risks.

## 6. **Compliance and Monitoring**

### 6.1 **Security Monitoring**
- **Google Cloud Security Command Center**: Monitors for vulnerabilities and misconfigurations in the environment.
- **Cloud IAP**: Ensures secure access to the application services, validating that users are authorized to access sensitive resources.

### 6.2 **Compliance Audits**
- Regular audits are performed to ensure compliance with SOC 2 and other applicable standards.

---