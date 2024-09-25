terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }

}
resource "aws_ecr_repository" "this" {
    name = var.repository_name
    image_tag_mutability = "MUTABLE"
   image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}
# # Separate resource for lifecycle policy
# resource "aws_ecr_repository_lifecycle_policy" "ecr_lifecycle_policy" {
#   repository_name = aws_ecr_repository.main.name
#   policy          = jsonencode(var.lifecycle_policy)
# }
