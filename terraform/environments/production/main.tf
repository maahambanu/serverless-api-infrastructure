module "app" {
  source      = "../../modules/app"
  environment = var.environment

  lambda_source_hash = var.
  lambda_artifact_key = var.lambda_artifact_key
}