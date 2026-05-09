module "app" {
  source      = "../../modules/app"
  environment = var.environment

  lambda_source_hash  = var.lambda_source_hash
  lambda_artifact_key = var.lambda_artifact_key

  alert_email = "mariacosgrov123@gmail.com"
}