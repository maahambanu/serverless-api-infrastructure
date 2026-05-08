module "app" {
  source      = "../../modules/app"
  environment = "staging"

  lambda_source_hash = var.lambda_source_hash
  lambda_artifact_key = var.lambda_artifact_key
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}