terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }

}
resource "aws_codebuild_project" "this" {
  name          = var.project_name
  build_timeout = var.build_timeout
  service_role  = var.service_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = var.compute_type
    image        = var.image
    type         = var.environment_type
# Add the environment variables
    dynamic "environment_variable" {
    for_each = var.environment_variables
    content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
    }
    }
  }

  source {
    type      = "CODEPIPELINE"  # Uses the source from the CodePipeline
    buildspec = "deploy/buildspec.yml"  # Pass this variable to specify the buildspec location
  }

  logs_config {
    cloudwatch_logs {
      group_name = var.cloudwatch_logs_group
      status     = "ENABLED"
    }
  }
}
