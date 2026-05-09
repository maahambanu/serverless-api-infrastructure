module "dynamodb" {
  source      = "../dynamodb"
  environment = var.environment
}

module "lambda" {
  source      = "../lambda"
  environment = var.environment

  alert_email = var.alert_email

  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn

  api_gateway_execution_arn = module.api_gateway.execution_arn
  
  lambda_artifact_bucket = "serverless-api-artifacts-mb"
  lambda_source_hash  = var.lambda_source_hash
  lambda_artifact_key = var.lambda_artifact_key
}

module "api_gateway" {
  source      = "../api_gateway"
  environment = var.environment

  lambda_arn = module.lambda.lambda_arn
}
