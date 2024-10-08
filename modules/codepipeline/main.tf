terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }

}

resource "aws_codepipeline" "pipeline" {
  name     = var.pipeline_name
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = "${var.github_owner}/${var.repo}"
        BranchName           = var.repo_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = var.codebuild_project_name

        # Conditional environment variables based on pipeline type
        EnvironmentVariables = jsonencode(
          flatten([
            var.pipeline_type == "frontend" ? [
              {
                name  = "S3_BUCKET_NAME"
                value = var.s3_name
                type  = "PLAINTEXT"
              },
              {
                name  = "DISTRIBUTION_ID"
                value = var.cloudfront_distribution
                type  = "PLAINTEXT"
              }, 
              {
                name  = "VITE_APP_API_URL"
                value = var.backend_url
                type  = "PLAINTEXT"
              },

            ] : [],
            var.pipeline_type == "backend" ? [
              {
                name  = "ECR_REGISTRY_URI"
                value = var.ecr_uri
                type  = "PLAINTEXT"
              },
              {
                name  = "ECR_REGION"
                value = var.ecr_region
                type  = "PLAINTEXT"
              },
              {
                name  = "ECS_CLUSTER"
                value = var.ecs_cluster_name
                type  = "PLAINTEXT"
              },
               {
                name  = "ECS_SERVICE"
                value = var.ecs_service_name
                type  = "PLAINTEXT"
              }
            ] : []
          ])
        )
      }
    }
  }
}