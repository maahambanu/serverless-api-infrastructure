resource "aws_dynamodb_table" "events" {
  name         = "events-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}

