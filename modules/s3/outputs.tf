# outputs.tf

output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "bucket_name" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}



