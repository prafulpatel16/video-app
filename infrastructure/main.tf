provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "video_bucket" {
  bucket = "video-upload-bucket"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
  }
}

resource "aws_dynamodb_table" "video_metadata" {
  name           = "video-metadata"
  hash_key       = "videoId"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "videoId"
    type = "S"
  }
}

resource "aws_lambda_function" "upload_handler" {
  function_name    = "video-upload-handler"
  runtime          = "python3.9"
  handler          = "upload_handler.lambda_handler"
  filename         = "backend.zip"
  source_code_hash = filebase64sha256("backend.zip")
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.video_bucket.bucket
      TABLE_NAME  = aws_dynamodb_table.video_metadata.name
    }
  }
  role = aws_iam_role.lambda_exec.arn
}

resource "aws_api_gateway_rest_api" "video_api" {
  name = "Video Upload API"
}

# Add routes and methods here
