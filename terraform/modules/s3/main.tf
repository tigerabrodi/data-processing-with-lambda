resource "aws_s3_bucket" "lambda_processor_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "lambda_bucket_control" {
  bucket = aws_s3_bucket.lambda_processor_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket_control]

  bucket = aws_s3_bucket.lambda_processor_bucket.id
  acl    = "private"
}


