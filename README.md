# Serverless API Infrastructure on AWS
## Overview

This project implements a production-oriented serverless API platform on AWS using Terraform and GitHub Actions. The solution demonstrates Infrastructure as Code (IaC), CI/CD automation, security scanning, environment isolation, observability, rollback strategy, and disaster recovery considerations.

The platform provisions:

- AWS Lambda (Node.js runtime)
- API Gateway HTTP API
- DynamoDB
- CloudWatch logging and alarms
- Terraform remote state management
- CI/CD pipeline with security checks and gated production deployments

![CI](https://github.com/maahambanu/serverless-api-infrastructure/actions/workflows/pipeline-terraform.yml/badge.svg)

## Engineering Decisions

This implementation intentionally prioritizes:
- operational simplicity
- safe deployments
- rollback capability
- environment isolation
- low operational overhead

The architecture uses serverless AWS services to minimize infrastructure management while still supporting production-grade deployment practices such as:
- immutable Lambda artifacts
- remote Terraform state locking
- manual production approvals
- security scanning
- rollback workflows
- disaster recovery considerations
  
## Architecture

## Pipeline Worflow
<img width="667" height="269" alt="image" src="https://github.com/user-attachments/assets/db099402-8bf6-4086-be1b-f036dbcaaff1" />

## Project Structure
```
.
├── app/
│   ├── handler.js
│   ├── package.json
│   ├── tests
│   └── eslint configuration
│
├── terraform/
│   ├── environments/
│   │   ├── staging/
│   │   └── production/
│   │
│   └── modules/
│       ├── lambda/
│       ├── api_gateway/
│       ├── dynamodb/
│       └── app/
│
├── .github/workflows/
│   ├── pipeline-terraform.yml
│   └── rollback.yml
│
├── README.md
├── OPERATIONS.md
└── DR.md
```

## Features Implemented
### Infrastructure as Code
- Terraform modular architecture
- Separate staging and production environments
- Remote Terraform state in S3
- DynamoDB state locking
- Environment isolation

### CI/CD Pipeline
Implemented using GitHub Actions.
#### Pipeline stages
- Node.js linting
- Unit testing (using Jest)
- Trivy security scanning
- Terraform validation
- Terraform planning
- Automatic staging deployment
- Manual production approval gate
- Production deployment
  
### Security
- Least privilege IAM policies
- Trivy dependency scanning
- Trivy IaC scanning
- Terraform state locking
- AWS SSM Parameter Store integration
- Environment isolation
- Artifact-based deployments

### Observability
- CloudWatch Logs
- Lambda error alarms
- Lambda duration alarms
- API Gateway 5XX alarms
- X-Ray tracing enabled

### Disaster Recovery
- DynamoDB Point-In-Time Recovery (PITR)
- Immutable Lambda artifact versioning
- Manual rollback workflow
- Remote Terraform state backup
  
## API Endpoints
### Health Endpoint
```
GET /health
```
Response:
```
{
  "status": "ok"
}
```
To test localy use this command (assuming you have already done the deployment)
```
terraform output
curl.exe https://<unique-id>.execute-api.ap-south-1.amazonaws.com/health
```
response: 
```
{"status":"ok"}
```
Please note that you can do the same with your browser. 
<img width="437" height="196" alt="image" src="https://github.com/user-attachments/assets/75d6b5c7-1517-48b4-9f98-76022eb4df7a" />

#### Infrastructure Validation

Infrastructure validation is performed in the GitHub Actions pipeline before deployment.

The validation stage includes:

- `terraform init` to initialize the backend and providers
- `terraform fmt -check -recursive` to enforce consistent Terraform formatting
- `terraform validate` to verify Terraform syntax and configuration correctness
- `terraform plan` to preview infrastructure changes before apply

This ensures that invalid or poorly formatted infrastructure code cannot progress to deployment.

#### Security Scan (Trivy)

Security scanning is performed using Trivy as part of the CI/CD pipeline.

Trivy scans:

- Node.js application dependencies
- Terraform Infrastructure as Code configuration

The pipeline fails when Trivy detects HIGH or CRITICAL findings.

This provides an early security gate before infrastructure changes are deployed to AWS.

## Deployment Strategy
### Staging
Automatically deployed after merge to main.

### Production
Protected using GitHub Environment approval gates.
Requires manual approval before deployment.

## Rollback Strategy
Deployments are immutable and artifact-based.
Each deployment uploads a versioned Lambda ZIP artifact to S3:
```
lambda-<commit-sha>.zip
```
Rollback is performed through a manual GitHub Actions workflow by redeploying a previously known-good artifact.
This avoids rebuilding historical application versions and provides deterministic recovery.

<img width="407" height="178" alt="image" src="https://github.com/user-attachments/assets/31a7147b-b4e6-48e7-b50f-232f6b8c8af2" />

## Terraform State Management

Terraform remote state is stored in:
- S3 bucket backend
- DynamoDB locking table

This prevents:
- concurrent deployments
- state corruption
- unsafe infrastructure changes
<img width="448" height="241" alt="image" src="https://github.com/user-attachments/assets/10c8b2eb-ec36-4e68-9af5-9ca732fb13c2" />
<img width="448" height="281" alt="image" src="https://github.com/user-attachments/assets/abe5fc7b-0f4e-4f11-9a53-0285569301a8" />

## Secrets and Configuration Management

Application configuration is externalized using:
- AWS Systems Manager Parameter Store (SSM)

CI/CD credentials are securely stored in:
- GitHub Actions Secrets

**No secrets are committed to the repository.**

## Monitoring & Alerting
Implemented CloudWatch alarms:
- Lambda Errors
- Lambda Duration
- API Gateway 5XX responses

These alarms support:

- elevated error rate detection
- timeout detection
- operational incident response
<img width="749" height="320" alt="image" src="https://github.com/user-attachments/assets/90b62473-ff01-443a-b842-beb8f7757406" />
<img width="938" height="320" alt="image" src="https://github.com/user-attachments/assets/9bddf191-ce02-4c23-8a1e-5d5ae53746ce" />

### Setup Instructions
Prerequisites:
- AWS Account
- Terraform >= 1.10
- Node.js >= 18
- AWS CLI configured
#### Install dependencies
```
cd app
npm install
```
#### Deploy staging
```
cd terraform/environments/staging
terraform init
terraform plan
terraform apply
```
#### Deploy production
```
cd terraform/environments/production
terraform init
terraform plan
terraform apply
```
Production deployments are additionally protected through GitHub approval gates.
## Design Decisions & Trade-offs
### Why DynamoDB instead of RDS
DynamoDB was selected for:
- lower operational overhead
- serverless scalability
- simpler disaster recovery
- cost efficiency
  
### Why artifact-based deployments
Lambda artifacts are versioned and stored in S3:
- deterministic rollback
- immutable deployments
- operational 

### Why Terraform modules
Modules improve:
- reusability
- maintainability
- environment consistency
  
### Why GitHub Actions
GitHub Actions was selected due to:
- repository-native CI/CD
- integrated environment approvals
- simplified operational workflow
- Future Improvements

The solution was designed for AWS Free Tier compatibility where possible:
- Lambda serverless execution
- DynamoDB on-demand billing
- API Gateway HTTP API
- CloudWatch basic monitoring

## Cost Considerations
The current implementation is intentionally optimized for low operational overhead and cost efficiency by leveraging serverless AWS services such as Lambda, API Gateway HTTP API, and DynamoDB On-Demand billing. This architecture is highly cost-effective for small to medium workloads because compute and database costs scale based on actual usage rather than pre-provisioned infrastructure.

For larger-scale scenarios, such as a healthcare platform with approximately 100 APIs and onboarding roughly 20,000 new users per month, the architecture would still scale operationally, but additional cost optimization strategies would become important. At higher traffic volumes, DynamoDB capacity modes may need to transition from On-Demand to Provisioned Capacity with Auto Scaling to better control predictable workloads. API Gateway and Lambda execution costs would also become significant contributors, making monitoring of invocation patterns, cold starts, and inefficient API calls increasingly important.

In a production-scale environment, further optimizations would likely include:
- introducing caching layers such as API Gateway caching or Redis/ElastiCache
- reducing Lambda cold starts through provisioned concurrency for critical APIs
- separating high-frequency and low-frequency workloads
- implementing lifecycle policies for CloudWatch Logs and S3 artifacts
- introducing centralized observability and cost monitoring dashboards
-  container-based workloads (ECS/EKS) for consistently high-throughput services where serverless pricing may become less economical

The current design prioritizes simplicity, operational safety, rapid deployment, and scalability, while still providing a clear evolutionary path toward larger-scale production workloads.

## Intentional Trade-offs

To keep the assignment focused and operationally simple, the following were intentionally not implemented:

- Blue/Green deployments
- Multi-region failover
- Canary deployments
- Cross-account AWS setup
- Kubernetes/EKS orchestration
- Complex observability stacks

The solution prioritizes:
- operational clarity
- reproducibility
- safe deployments
- rollback simplicity
- low operational overhead

## Future Improvements

Potential production-scale enhancements:

- GitHub OIDC federation
- Canary deployments
- Blue/Green deployments
- Cross-region failover
- Slack/SNS alerting
- WAF integration
- Centralized observability dashboards

## Security Posture

Security controls implemented include:

- dedicated IAM user for CI/CD
- least privilege IAM policies
- Trivy dependency and IaC scanning
- Terraform state locking
- externalized configuration via AWS SSM
- immutable deployment artifacts
- manual production approval gates
- CloudWatch operational monitoring
