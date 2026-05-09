variable "environment" {
  type = string
}

variable "lambda_source_hash" {
  description = "Base64 encoded SHA256 hash of Lambda artifact"
  type        = string
}

variable "lambda_artifact_key" {
  description = "S3 object key for Lambda artifact"
  type        = string
}

variable "alert_email" {
  description = "Email address for operational alerts"
  type        = string
}