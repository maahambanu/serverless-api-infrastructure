### Serverless API Infrastructure on AWS
# Overview

This project implements a production-oriented serverless API platform on AWS using Terraform and GitHub Actions. The solution demonstrates Infrastructure as Code (IaC), CI/CD automation, security scanning, environment isolation, observability, rollback strategy, and disaster recovery considerations.

The platform provisions:

- AWS Lambda (Node.js runtime)
- API Gateway HTTP API
- DynamoDB
- CloudWatch logging and alarms
- Terraform remote state management
- CI/CD pipeline with security checks and gated production deployments