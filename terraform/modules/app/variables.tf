variable "environment" {
  type = string
}

variable "lambda_source_hash" {
  description = "Base64 encoded SHA256 hash of Lambda artifact"
  type        = string
}
