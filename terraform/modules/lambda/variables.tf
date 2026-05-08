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