resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/api-${var.environment}"
  retention_in_days = 14

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.api.function_name
  }

  alarm_description = "Alarm when Lambda has errors"

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "lambda-duration-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Average"
  threshold           = 3000

  dimensions = {
    FunctionName = aws_lambda_function.api.function_name
  }

  alarm_description = "Alarm when Lambda duration is too high"

  tags = {
    Environment = var.environment
  }
}