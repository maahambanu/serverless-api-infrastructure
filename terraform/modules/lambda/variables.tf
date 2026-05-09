variable "environment" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  type        = string
}

variable "api_gateway_execution_arn" {
  type        = string
  description = "Execution ARN of API Gateway"
}

variable "lambda_artifact_key" {
  description = "S3 object key for Lambda artifact"
  type        = string
}

variable "lambda_source_hash" {
  description = "Base64 encoded SHA256 hash of Lambda artifact"
  type        = string
}