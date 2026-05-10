# Disaster Recovery Strategy
Overview
This document describes the disaster recovery (DR) strategy for the serverless API platform deployed on AWS.

The platform consists of:
- AWS Lambda
- API Gateway HTTP API
- DynamoDB
- CloudWatch Logs and Alarms
- Terraform-managed infrastructure
- GitHub Actions CI/CD pipeline

The DR approach focuses on:
- infrastructure reproducibility
- immutable deployments
- rapid rollback capability
- state protection
- data recovery
## Recovery Objectives

| Objective | Target |
|---|---|
| Recovery Time Objective (RTO) | ~15–30 minutes |
| Recovery Point Objective (RPO) | Near real-time for DynamoDB with PITR |

## Recovery Strategy
The platform uses an Infrastructure as Code recovery model.
Infrastructure is reproducible using Terraform, while application deployments are immutable and stored as versioned Lambda artifacts in S3.
Recovery is based on:
- Terraform redeployment
- rollback to previous Lambda artifacts
- DynamoDB Point-In-Time Recovery
- remote Terraform state restoration

## Components Protected

| Component | Protection Strategy |
|---|---|
| Lambda application | Versioned immutable S3 artifacts |
| DynamoDB data | Point-In-Time Recovery (PITR) |
| Terraform state | Remote S3 backend |
| Terraform locking | DynamoDB lock table |
| CI/CD pipeline | GitHub Actions workflow versioning |
| Logs & monitoring | CloudWatch retention |

## Lambda Recovery Strategy
Lambda deployments are artifact-based.

Each deployment uploads a versioned artifact:
```
lambda-<commit-sha>.zip
```
Example:
```
lambda-325ea1232a03475ba43fe79474e8d6bfa1121a87.zip
```
Artifacts are stored in:
```
serverless-api-artifacts-<uid>
```
## Rollback Procedure
### Scenario
A deployment introduces:
- application bugs
- API failures
- increased Lambda errors
- operational instability
### Recovery Steps
1. Open GitHub Actions.
2. Trigger the Manual Rollback workflow.
3. Select:
  - target environment
  - previous known-good Lambda artifact
4. Re-run Terraform deployment using the older artifact.

Example rollback artifact:
```
lambda-325ea1232a03475ba43fe79474e8d6bfa1121a87.zip
```
The rollback workflow recalculates the Lambda source hash automatically.
No rebuild is required.
DynamoDB Recovery Strategy

## DynamoDB Point-In-Time Recovery (PITR) is enabled.
Purpose:
- protects against accidental deletion
- protects against bad writes
- supports recovery from faulty deployments
- enables table restoration to a previous timestamp
This is important because the /event endpoint writes operational data into DynamoDB.

## DynamoDB Restore Process
### Scenario
A faulty deployment corrupts or deletes application data.
### Recovery Steps
1. Open AWS Console.
2. Navigate to DynamoDB.
3. Select the affected table.
4. Open:
  - Backups
  - Point-in-time recovery
5. Restore the table to a selected timestamp.

The restored table can then:
- replace the active table
- or be used for data migration/recovery

## Terraform State Recovery
Terraform remote state is stored in:
- S3 backend bucket
- DynamoDB lock table

This protects infrastructure state from:
- local machine loss
- concurrent Terraform operations
- inconsistent deployments

## State Lock Recovery

If Terraform operations fail unexpectedly, stale locks may remain.

### Recovery Steps
1. Verify no deployment is currently running.
2. Inspect the lock file:
```
terraform.tfstate.tflock
```
3. Preferred recovery method:
```
terraform force-unlock <LOCK_ID>
```
4. If necessary, manually delete only the lock file from S3.
Do not delete:
```
terraform.tfstate
```

## CI/CD Recovery Strategy
The CI/CD pipeline itself is version controlled inside GitHub.
Recovery capabilities include:
- rollback to previous commits
- redeploying historical Lambda artifacts
- restoring Terraform-managed infrastructure

GitHub Actions concurrency control is enabled to prevent overlapping deployments:
```
concurrency:
  group: terraform-staging
  cancel-in-progress: true
```
This reduces the risk of:
- Terraform state corruption
- duplicate deployments
- race conditions
## Monitoring & Incident Detection
CloudWatch alarms are configured for:
- Lambda Errors
- Lambda Duration
- API Gateway 5XX responses

These alarms support rapid detection of:
- failed deployments
- elevated error rates
- performance regressions

## What Should Be Tested Regularly
### Deployment Recovery Testing
Validate:
- rollback workflow execution
- previous artifact deployment
- Terraform recovery behavior
### DynamoDB Recovery Testing
Validate:
- PITR restore capability
- restored table integrity
- recovery timing
### Terraform Backend Recovery
Validate:
- state lock recovery process
- remote backend accessibility
- infrastructure reproducibility

## Regular DR Testing

### Monthly: Rollback test (staging)
1. Identify the second-most-recent artifact in S3
2. Trigger the Manual Rollback workflow against staging
3. Provide the previous artifact key
4. Verify `/health` returns `{"status":"ok"}` after rollback
5. Redeploy current version to restore staging

**Pass criteria:** rollback completes in under 15 minutes

### Quarterly: DynamoDB PITR restore test
1. Note current timestamp
2. Write 3–5 test records via `POST /event`
3. In DynamoDB console, restore table to pre-write timestamp
4. Verify test records are absent in the restored table
5. Delete restored table after verification

**Pass criteria:** restore completes, data state matches expected point in time

### Quarterly: Full infrastructure redeploy test
1. Run `terraform destroy` against staging
2. Run `terraform apply` from scratch
3. Verify all resources recreate cleanly
4. Verify `/health` endpoint responds

**Pass criteria:** full redeploy completes in under 30 minutes with no manual steps
## Failure Scenarios and Recovery Actions

| Scenario | Impact | Recovery Action | Estimated RTO |
|---|---|---|---|
| Bad code deployment | API errors / failures | Trigger rollback workflow with previous artifact | ~10 min |
| Lambda misconfiguration | API unavailable | `terraform apply` with corrected config | ~10 min |
| DynamoDB data corruption | Event data loss/corruption | PITR restore to pre-corruption timestamp | ~20 min |
| Terraform state corruption | Deployments blocked | Restore `terraform.tfstate` from S3 versioning | ~15 min |
| Full environment loss | Complete outage | `terraform apply` from scratch against fresh environment | ~30 min |
