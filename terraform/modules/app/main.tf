module "dynamodb" {
  source      = "../dynamodb"
  environment = var.environment
}

module "lambda" {
  source      = "../lambda"
  environment = var.environment

  dynamodb_table_name = module.dynamodb.table_name
}

module "api_gateway" {
  source      = "../api_gateway"
  environment = var.environment

  lambda_arn = module.lambda.lambda_arn
}