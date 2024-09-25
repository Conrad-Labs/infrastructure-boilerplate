# codebuild_project/outputs.tf

output "codebuild_project_arn" {
  description = "The ARN of the CodeBuild project"
  value       = aws_codebuild_project.this.arn
}

output "codebuild_project_name" {
  description = "The name of the CodeBuild project"
  value       = aws_codebuild_project.this.name
}
