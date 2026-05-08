resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "serverless-api-artifacts-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}