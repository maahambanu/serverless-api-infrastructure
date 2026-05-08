variable "environment" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "api_gateway_execution_arn" {
  type        = string
  description = "Execution ARN of API Gateway"
}