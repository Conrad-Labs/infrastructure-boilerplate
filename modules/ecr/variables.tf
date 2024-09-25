variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Can be MUTABLE or IMMUTABLE."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "If true, images are scanned after being pushed."
  type        = bool
  default     = true
}

variable "lifecycle_policy" {
  description = "ECR lifecycle policy"
  type        = map(any)
  default = {
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
}

variable "tags" {}
