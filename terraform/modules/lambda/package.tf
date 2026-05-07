data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../app/handler.js"
  output_path = "${path.module}/lambda.zip"
}