resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = var.dynamodb_table_arn
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts_lifecycle" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  rule {
    id     = "cleanup-old-artifacts"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

resource "aws_lambda_function" "api" {

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs
  ]

  function_name = "api-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.handler"
  runtime       = "nodejs18.x"

  s3_bucket = var.lambda_artifact_bucket
  s3_key    = var.lambda_artifact_key

  reserved_concurrent_executions = 10

  source_code_hash = var.lambda_source_hash

  environment {
    variables = {
      ENV                 = var.environment
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/*"
}