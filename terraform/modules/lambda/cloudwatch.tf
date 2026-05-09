resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/api-${var.environment}"
  retention_in_days = 14

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}

# Lambda Error Alarm

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_actions = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.api.function_name
  }

  treat_missing_data = "notBreaching"

  alarm_description = "Triggers when Lambda records more than 1 error within 60 seconds"

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}

# Lambda Duration / Timeout Alarm

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "lambda-duration-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Average"

  # milliseconds
  threshold = 3000

  alarm_actions = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.api.function_name
  }

  treat_missing_data = "notBreaching"

  alarm_description = "Triggers when Lambda average duration exceeds 3 seconds"

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}