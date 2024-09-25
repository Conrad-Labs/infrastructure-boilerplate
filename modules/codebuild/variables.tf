
variable "project_name" {
  description = "The name of the CodeBuild project"
  type        = string
}


variable "build_timeout" {
  description = "The timeout for the build in minutes"
  type        = string
  default =  "60"
}

variable "service_role_arn" {
  description = "The ARN of the IAM role used by CodeBuild"
  type        = string
}

variable "compute_type" {
  description = "The compute type for the build environment"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  description = "The Docker image to use for the build environment"
  type        = string
  default     = "aws/codebuild/standard:5.0"
}

variable "environment_type" {
  description = "The environment type for the build"
  type        = string
  default     = "LINUX_CONTAINER"
}

# variable "ecr_repo_name" {
#   description = "The name of the ECR repository"
#   type        = string
# }

# variable "ecr_repo_arn" {
#   description = "The ARN of the ECR repository"
#   type        = string
# }

variable "source_type" {
  description = "The source type for the build"
  type        = string
  default     = "GITHUB"
}

# variable "buildspec" {
#   description = "The build specification file path"
#   type        = string
# }

variable "cloudwatch_logs_group" {
  description = "The CloudWatch Logs group name"
  type        = string
}

variable "environment_variables" {
description = "A list of maps that defines environment variables for the build project"
type        = list(object({
name  = string
value = string
}))
default = []
}

variable "tags" {}
