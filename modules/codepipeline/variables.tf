variable "codestar_connection_arn" {
  description = "The ARN of the CodeStar connection to use for GitHub."
  type        = string
}

variable "github_owner" {
  description = "The owner of the GitHub repository."
  type        = string
}

variable "repo" {
  description = "The name of the GitHub repository."
  type        = string
}

variable "pipeline_name" {
  description = "The name of the Pipeline"
  type        = string
}

variable "repo_branch" {
  description = "The branch of the backend repository to monitor."
  type        = string
  default     = "main"  # Default to main, change if needed
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster for deployment."
  type        = string
  default = ""
}

variable "ecs_service_name" {
  description = "The name of the ECS service for deployment."
  type        = string
  default = ""
}

variable "pipeline_type" {
  description = "The type of pipeline."
  type        = string
}

variable "artifact_bucket" {
  description = "The name of the S3 bucket to store pipeline artifacts."
  type        = string
}

variable "s3_name" {
  description = "The name of the S3 bucket frontend is deployed in."
  type        = string
  default = ""
}

variable "codebuild_project_name" {
  description = "Codebuild Project Name"
  type        = string
}

variable "ecr_region" {
description = "Region"
type        = string
default = ""
}

variable "cloudfront_distribution" {
type        = string
default = ""
}

variable "ecr_uri" {
type        = string
default = ""
}

variable "backend_url" {
  default = ""
  
}

variable "tags" {}

variable "codepipeline_role_arn" {
  
}

# variable "codepipeline_role" {
#   description = "The IAM role ARN for CodePipeline"
#   type        = string
# }
