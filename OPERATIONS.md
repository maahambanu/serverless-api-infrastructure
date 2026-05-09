# Overview

This document describes the operational procedures, monitoring setup, rollback strategy, and incident handling process for the serverless API platform.

The platform consists of:
- AWS Lambda
- API Gateway HTTP API
- DynamoDB
- CloudWatch Logs and Alarms
- Terraform-managed infrastructure
- GitHub Actions CI/CD pipeline

## Environments
Two isolated environments are deployed:
| Environment | Purpose  |
|---|---|
| staging | Integration testing and validation   |
| production | Live production workload  |

Each environment has:
- separate Lambda functions
- separate DynamoDB tables
- separate Terraform state
- separate API Gateway deployment

## Deployment Process
### Staging Deployment

Triggered automatically after merge to main.

Pipeline stages:
1. Lint
2. Unit tests
3. Security scanning
4. Terraform validation
5. Terraform plan
6. Terraform apply (staging)


### Production Deployment
Production deployments require manual approval through GitHub Environments.

Pipeline stages:
1. Staging deployment succeeds
2. Manual approval required
3. Terraform apply (production)

### Infrastructure Validation

Infrastructure validation includes:
- ```terraform fmt -check -recursive```
- ```terraform validate```
- ```terraform plan```

This prevents invalid infrastructure changes from being deployed.

## Security Scanning
Security scanning is implemented using Trivy.

Scans performed:
- Node.js dependency vulnerabilities
- Terraform IaC misconfigurations

The CI/CD pipeline fails on:
- HIGH findings
- CRITICAL findings

## Logging
Application logs are stored in:
- AWS CloudWatch Logs

Log group naming convention:
```
/aws/lambda/api-staging
/aws/lambda/api-production
```
Structured JSON logging is implemented inside the Lambda function.

Example log:
```
{
  "level": "INFO",
  "message": "Request received",
  "method": "GET",
  "path": "/health"
}
```
## Metrics & Monitoring

### CloudWatch Alarms

The following alarms are configured:

| Alarm | Purpose |
|---|---|
| Lambda Errors | Detect failed Lambda executions |
| Lambda Duration | Detect elevated execution duration |
| API Gateway 5XX | Detect backend/API failures |

## Operational Runbooks
### Elevated Error Rate
Symptoms
- CloudWatch Lambda Errors alarm triggered
- Increased API failures
- HTTP 5XX responses
### Investigation Steps
1. Check CloudWatch Logs:
```
CloudWatch → Log Groups → /aws/lambda/api-<environment>
```
2. Review:
  - stack traces
  - request payloads
  - failed API routes
3. Validate:
  - Lambda deployment version
  - API Gateway integration
  - DynamoDB availability
### Mitigation
- Roll back to previous known-good Lambda artifact (check Rollback section) 
- Re-run deployment pipeline if deployment incomplete
### Lambda Timeouts
#### Symptoms
- Lambda Duration alarm triggered
- Increased latency
- API timeout responses
#### Investigation Steps
1. Review Lambda duration metrics
2. Inspect recent deployments
3. Check DynamoDB latency
4. Review CloudWatch logs for slow operations
### Mitigation
- Roll back deployment if regression introduced
- Increase Lambda timeout temporarily if required
- Optimize handler logic

## Failed Deployment
### Symptoms
- GitHub Actions deployment failure
- Terraform apply failure
- Partial infrastructure update
### Investigation Steps
1. Review GitHub Actions logs
2. Identify failing Terraform resource
3. Verify Terraform state lock status
4. Check AWS service availability
### Mitigation
- Resolve Terraform errors
- Retry deployment
- Force unlock Terraform state only if confirmed stale

## Rollback Procedure
Deployments are artifact-based and immutable.
Lambda ZIP artifacts are uploaded to S3 with commit SHA naming:
```
lambda-<commit-sha>.zip
```
<img width="691" height="301" alt="image" src="https://github.com/user-attachments/assets/64898b41-0d8d-435a-8abb-bf7252e2d87b" />

Rollback is performed by redeploying a previous artifact.

### Rollback Steps
1. Identify last known-good deployment artifact
2. Trigger rollback GitHub Actions workflow
3. Provide:
  - previous artifact key
  - corresponding source hash
  - Execute Terraform apply

### How to find the previous artifact key
1. Go to AWS Console.
2. Open S3.
3. Open the artifact bucket
```
serverless-api-artifacts-<uid>
```
4. Look for previous Lambda ZIP files:
```
lambda-<commit-sha>.zip
```
5. Select the last known-good artifact. This is the ```lambda_artifact_key.```
Example:
```
lambda_artifact_key = lambda-325ea1232a03475ba43fe79474e8d6bfa1121a87.zip
```
### How to find the corresponding source hash
The rollback workflow downloads the selected artifact from S3 and regenerates the Lambda source hash automatically.

Therefore, during rollback, the operator only needs to provide:
```
environment
lambda_artifact_key
```
The workflow calculates:
```
lambda_source_hash
```
internally before running Terraform.
### How to trigger rollback
1. Go to GitHub repository.
2. Open the Actions tab.
3. Select the Manual Rollback workflow.
4. Click Run workflow.
5. Select the target environment:
```
staging
production
```
6. Enter the previous known-good artifact key:
```
Enter the previous known-good artifact key:
```
7. Run the workflow.
For production, the rollback workflow is still protected by the GitHub production environment approval gate.
#### What rollback does
Rollback updates the Lambda function to use the selected previous S3 artifact:
```
s3_key = "lambda-<previous-good-commit-sha>.zip"
```
  
## Terraform State Management
Terraform remote state is stored in an S3 backend and protected with state locking.
This prevents multiple Terraform operations from modifying the same state at the same time.

This prevents:
- concurrent deployments
- state corruption
- unsafe infrastructure drift
## Concurrency control in GitHub Actions
The pipeline also includes GitHub Actions concurrency control:
```
concurrency:
  group: terraform-staging
  cancel-in-progress: true
```
This prevents overlapping workflow runs from applying Terraform against the same environment simultaneously.

Purpose:
- prevents duplicate deployments
- reduces risk of Terraform state lock conflicts
- avoids two pipeline runs modifying the same infrastructure at once
- keeps deployment behavior predictable

## If Terraform state becomes locked
If a pipeline fails or is cancelled during a Terraform operation, the state lock may remain temporarily.
First:
1. Make sure no GitHub Actions workflow is still running.
2. Make sure no local ```terraform plan``` or ```terraform apply``` is running.
Then inspect the backend bucket:
```
S3 → my-terraform-state-bucket-mb → staging/
```
If this file exists:
```
If this file exists:
```
delete only:
```
terraform.tfstate.tflock
```
Do not delete:
```
terraform.tfstate
```
If Terraform provides a lock ID, the preferred command is:
```
terraform force-unlock <LOCK_ID>
```
Example:
```
terraform force-unlock d88b3fe8-3202-2092-db3e-5c1493fc10f8
```
Only force-unlock when you are sure no Terraform operation is still running.

## DynamoDB Point-In-Time Recovery
DynamoDB Point-In-Time Recovery is enabled for the application event tables.
Purpose:
- protects event data from accidental deletion or corruption
- allows recovery to a previous point in time
- improves disaster recovery posture
- supports rollback scenarios where a bad deployment writes incorrect data

This is especially useful for the POST /event endpoint because it writes data into DynamoDB.

If bad data is written due to a faulty deployment, PITR provides a recovery option for the data layer in addition to the Lambda artifact rollback.

## Disaster Recovery Considerations
Implemented DR capabilities:
- DynamoDB Point-In-Time Recovery (PITR)
- Versioned Lambda artifacts
- Remote Terraform state backup
- Infrastructure reproducibility through Terraform

## Secrets Management
Secrets and runtime configuration are externalized using:
- AWS Systems Manager Parameter Store (SSM)
CI/CD credentials are stored securely in:
- GitHub Actions Secrets
No secrets are committed to source control.

## Operational Best Practices Implemented
- Infrastructure as Code
- Immutable deployments
- Environment isolation
- Least privilege IAM
- Automated CI/CD validation
- Security scanning
- Structured logging
- Alarm-based monitoring
- Manual production approval gates
- Remote Terraform state locking
