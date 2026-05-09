resource "aws_sns_topic" "alerts" {
  name = "serverless-api-alerts-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = "serverless-api"
  }
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}