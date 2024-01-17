# Lambda Function
resource "aws_lambda_function" "data_processor" {
  function_name = var.function_name
  runtime       = "nodejs14.x"
  handler       = "index.handler" # index.js -> exporting handler function as "handler"

  filename = "${path.module}/function.zip"

  # The source_code_hash attribute is used to determine if the function's deployment package has changed.
  # If the source_code_hash is provided, then the function will only be updated if the hash of the current file does not match the hash that is provided.
  # This helps to prevent unnecessary updates to the function when no changes have been made to the deployment package.
  source_code_hash = filebase64sha256("${path.module}/function.zip")

  # IAM role that the Lambda function assumes
  role = aws_iam_role.lambda_role.arn
}

# IAM Role for Lambda
# By establishing the trust relationship that allows lambda.amazonaws.com to assume the IAM role, you effectively transform your handler (the code) into a fully operational AWS Lambda function.
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.bucket_name}/*",
      },
      # Permission to write logs to CloudWatch
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ],
  })
}


resource "aws_lambda_permission" "allow_s3_to_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}


resource "aws_s3_bucket_notification" "lambda_bucket_notification" {
  bucket = var.bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  # Depends on is important to ensure the Lambda permission is in place
  depends_on = [aws_lambda_permission.allow_s3_to_invoke]
}
