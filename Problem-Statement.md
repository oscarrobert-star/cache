# Senior DevOps Engineer Take Home Assessment

## Objective

Set up a **secure**, **production-grade** infrastructure on **GCP using Terraform**, and deploy a simple app that integrates with **Pub/Sub**, **PostgreSQL**, and **ELK Stack**. The pipeline must support **CI/CD via GitHub**, start with **4 active app nodes**, and comply with basic **SOC 2 readiness**.

---

## Requirements

### 1. Infrastructure Provisioning (Terraform preferred)

Provision the following resources:

- ✅ VPC + subnets (**staging** and **prod**)
- ✅ GKE cluster (with **staging** & **production** namespaces)
- ✅ Pub/Sub topic and subscription
- ✅ PostgreSQL (Cloud SQL or self-hosted)
- ✅ ELK Stack (self-hosted or via GCP marketplace)
- ✅ IAM roles & policies (**least privilege** principle)
- ✅ Secret Manager entries (DB credentials, Pub/Sub credentials, etc.)
- ✅ *(Optional)* Bastion host to simulate VPN access

---

### 2. App Example (Use provided repo or your own)

The app must:

- Provide a simple API with a `/health` endpoint
- Publish a message to **Pub/Sub**
- Insert data into **PostgreSQL**
- Emit structured logs readable via **Kibana**
- Deploy with **4 active nodes** (e.g., GKE or Cloud Run min instances)
- Be containerized with **environment-specific configuration**

---

### 3. CI/CD

Use **Cloud Build** or **GitHub Actions** to:

- Build, test, and deploy the app on push to `main`
- Securely pull secrets from **Secret Manager**
- Deploy to the correct namespace (`staging` or `prod`)

---

### 4. Observability

Integrate the **ELK Stack** for log aggregation and analysis:

- Logs from app should flow into **Logstash**, stored in **Elasticsearch**
- View logs via **Kibana**

---

### 5. Access & Security

- Define IAM role assignments and enable audit controls
- Secure all secrets using **Secret Manager**
- *(Optional)* Provide a VPN placeholder via **Bastion host**
- Enable **SSH access logging** on Bastion

---

### 6. (Optional Bonus)

- Create a GitHub Actions workflow that deploys only to the **staging** environment.

---

## Deliverables

- ✅ `Terraform` or `shell scripts` for provisioning
- ✅ Dockerized app with **staging** and **production** variants
- ✅ Cloud Build pipeline YAMLs *(or GitHub Actions workflows)*
- ✅ `README.md` with architecture & setup instructions
- ✅ `infra-docs.md` for IAM, secrets, audit setup, and SOC 2 alignment
- ✅ *(Optional)* GitHub Actions workflow for staging deployment

---

## Evaluation Criteria

- ✅ Completeness of infrastructure setup and provisioning
- ✅ Secure secret management practices
- ✅ Modular and reusable Terraform configurations
- ✅ Adherence to IAM best practices and access controls
- ✅ CI/CD pipeline functionality and quality
- ✅ VPN access setup and environment isolation
- ✅ Logging & observability via ELK or equivalent
- ✅ Clarity and audit-friendliness of documentation
- ✅ SOC 2-aligned configuration realism

---

## Checklist

- [ ] Infrastructure automation for at least **two environments**
- [ ] CI/CD (Cloud Build or GitHub Actions) with **secure secret handling**
- [ ] Dockerized app deployment to **Cloud Run or GKE**
- [ ] Pub/Sub topic and listener **stubbed or simulated**
- [ ] Logging pipeline to **ELK** or equivalent tool
- [ ] Firestore logging or **audit trail sample**
- [ ] **VPN config** stub or detailed description
- [ ] `infra-docs.md` showing **IAM audit & SOC 2 alignment**
- [ ] Clear `README.md` with **setup instructions** and **technical rationale**

---
