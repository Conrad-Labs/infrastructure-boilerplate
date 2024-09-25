# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

# ####################################### CodeBuild Role #######################################
# data "aws_iam_policy_document" "codebuild_policy" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["codebuild.amazonaws.com"]
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "codebuild_project_role" {
#   name               = "codebuild-role"
#   assume_role_policy = data.aws_iam_policy_document.codebuild_policy.json
# }

# resource "aws_iam_policy" "codebuild_policy" {
#   name        = "codebuild-policy"
#   description = "A policy for codebuild to write to cloudwatch, s3, and access SSM"
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": [
#           "cloudwatch:*",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:CreateLogGroup",
#           "logs:DescribeLogStreams"
#         ],
#         "Resource": "*",
#         "Effect": "Allow"
#       },
#       {
#         "Action" = [
#           "s3:Get*",
#           "s3:PutBucketVersioning",
#           "s3:List*",
#           "s3:UpdateObject",
#           "s3:PutEncryptionConfiguration",
#           "s3:PutObject",
#           "s3:PutBucketPublicAccessBlock",
#           "s3:CreateBucket"
#         ]
#         "Effect"   = "Allow"
#         "Resource": [
#         "arn:aws:s3:::${module.s3_artifact.bucket_name}", // The bucket itself
#         "arn:aws:s3:::${module.s3_artifact.bucket_name}/*", // All objects in the bucket
#         "arn:aws:s3:::${module.S3_Frontend.bucket_name}", // The bucket itself
#         "arn:aws:s3:::${module.S3_Frontend.bucket_name}/*" // All objects in the bucket
#       ]
#       },
#       {
#         Action = [
#           "ecs:CreateCluster",
#           "ecs:CreateService",
#           "ecs:DeleteCluster",
#           "ecs:DeleteService",
#           "ecs:DeregisterTaskDefinition",
#           "ecs:Describe*",
#           "ecs:PutClusterCapacityProviders",
#           "ecs:RegisterTaskDefinition",
#           "ecs:UpdateCluster",
#           "ecs:UpdateService",
#           "ecs:TagResource"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#       {
#         Action = [
#           "ecr:DescribeRepositories",
#           "ecr:CreateRepository",
#           "ecr:ListTagsForResource",
#           "ecr:TagResource",
#           "ecr:SetRepositoryPolicy",
#           "ecr:GetRepositoryPolicy",
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#       {
#         "Action": [
#           "ssm:GetParameter",
#           "ssm:GetParameters"
#         ],
#         "Effect": "Allow",
#         "Resource": [
#           "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/path/*"
#         ]
#       },
#       {
#         "Action": [
#           "cloudfront:CreateInvalidation",
#         ],
#         "Effect": "Allow",
#         "Resource": [
#           "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
#   role       = aws_iam_role.codebuild_project_role.name
#   policy_arn = aws_iam_policy.codebuild_policy.arn
# }

# ####################################### CodePipeline Role #######################################

# resource "aws_iam_role" "codepipeline_role" {
#   name = "appexample-dev-codepipeline-role"
#   assume_role_policy = jsonencode({
#     Version: "2012-10-17",
#     Statement: [
#       {
#         "Effect": "Allow",
#         "Principal": {
#           "Service": "codepipeline.amazonaws.com"
#         },
#         "Action": "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "codepipeline_execution_policy" {
#   name        = "codepipeline-policy"
#   description = "A policy with permissions for codepipeline to start builds, access SSM, CloudWatch, and S3"
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": ["codebuild:StartBuild", "codebuild:BatchGetBuilds"],
#         "Resource": "*"
#       },{
#         Effect = "Allow"
#         Action = [
#           "codestar-connections:PassConnection",
#           "codestar-connections:UseConnection"
#         ]
#         Resource = "codestar_connection_arn"
#       },
#       {
#         "Effect": "Allow",
#         "Action": ["cloudwatch:*"],
#         "Resource": "*"
#       },
#       {
#         "Action" = [
#           "s3:Get*",
#           "s3:PutBucketVersioning",
#           "s3:List*",
#           "s3:UpdateObject",
#           "s3:PutEncryptionConfiguration",
#           "s3:PutObject",
#           "s3:PutBucketPublicAccessBlock",
#           "s3:CreateBucket"
#         ]
#         "Effect"   = "Allow"
#         "Resource" = "arn:aws:s3:::${module.s3_artifact.bucket_name}/*"
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#           "ssm:GetParameter",
#           "ssm:GetParameters"
#         ],
#         "Resource": [
#           "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/path/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
#   role       = aws_iam_role.codepipeline_role.name
#   policy_arn = aws_iam_policy.codepipeline_execution_policy.arn
# }

# ####################################### ECS Task Role #######################################

# resource "aws_iam_role" "ecs_task_role" {
#   name = "appexample-dev-ecs-task-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         "Effect": "Allow",
#         "Principal": {
#           "Service": "ecs-tasks.amazonaws.com"
#         },
#         "Action": "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "ecs_task_policy" {
#   name        = "appexample-dev-ecs-task-policy"
#   description = "A policy for ECS task role to access S3, CloudWatch, SSM, ECR, and Secrets Manager"
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:ListBucket"
#         ],
#         "Resource": [
#           "arn:aws:s3:::app-user",
#           "arn:aws:s3:::app-user/*"
#         ]
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:CreateLogGroup"
#         ],
#         "Resource": "arn:aws:logs:*:*:*"
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchGetImage",
#           "ecr:BatchCheckLayerAvailability"
#         ],
#         "Resource": "*"
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#           "ssm:GetParameter",
#           "ssm:GetParameters"
#         ],
#         "Resource": [
#           "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/path/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.ecs_task_policy.arn
# }
