variable "environment" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "alert_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
}