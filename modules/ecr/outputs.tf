output "repository_url" {
  description = "The URI of the ECR repository"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.this.name
}
