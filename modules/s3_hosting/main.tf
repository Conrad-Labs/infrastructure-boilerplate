terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }

}

resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name

  tags = {
    Name = "S3-${var.bucket_name}"
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_s3_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.frontend.arn}/*"
        }
    ]
})
  depends_on = [ aws_s3_bucket_acl.acl_public_read ]
}

resource "aws_s3_bucket_acl" "acl_public_read" {
  bucket = aws_s3_bucket.frontend.id
  acl = "public-read"

  depends_on = [aws_s3_bucket_ownership_controls.example, aws_s3_bucket_public_access_block.example]
}
