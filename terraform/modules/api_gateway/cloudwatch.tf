resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx" {
  alarm_name          = "api-gateway-5xx-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xx"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 5

  dimensions = {
    ApiId = aws_apigatewayv2_api.api.id
  }

  treat_missing_data = "notBreaching"

  alarm_description = "Triggers when API Gateway returns too many 5XX responses"

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}