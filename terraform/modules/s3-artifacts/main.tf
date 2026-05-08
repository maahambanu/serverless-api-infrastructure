resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "serverless-api-artifacts-mb"

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}

# BLOCK ALL PUBLIC ACCESS

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CREATE KMS KEYS

resource "aws_kms_key" "s3_kms" {
  description             = "KMS key for Lambda artifact bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}

# ENABLE VERSIONING

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ENABLE SERVER SIDE ENCRYPTION

resource "aws_kms_alias" "s3_kms_alias" {
  name          = "alias/serverless-api-${var.environment}"
  target_key_id = aws_kms_key.s3_kms.key_id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms.arn
      sse_algorithm     = "AES256"
    }
  }
}