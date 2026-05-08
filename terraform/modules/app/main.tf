module "dynamodb" {
  source      = "../dynamodb"
  environment = var.environment
}

module "lambda" {
  source      = "../lambda"
  environment = var.environment

  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  api_gateway_execution_arn = module.api_gateway.execution_arn
}

module "api_gateway" {
  source      = "../api_gateway"
  environment = var.environment

  lambda_arn = module.lambda.lambda_arn
}