module "app" {
  source      = "../../modules/app"
  environment = var.environment
  lambda_source_hash = var.lambda_source_hash
}