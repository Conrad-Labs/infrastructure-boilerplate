provider "aws" {
  region = "us-east-2"
}

locals {
  common_tags = {
    Project = "${var.project_name}"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#DB Creation and Parameter store dealing will be through console 
variable "aws_region" {}
variable "route53_zone_name" {}
variable "acm_cert_domain_name" {}
variable "s3_bucket_name" {}
variable "cloudfront_s3_bucket_name" {}
variable "cloudfront_domain_name" {}
variable "cloudfront_alias" {}
variable "route53_domain_name" {}
variable "route53_record_name" {}
variable "jwt_token_parameter_arn" {}
variable "db_hostname_arn" {}
variable "db_username_arn" {}
variable "db_password_arn" {}
variable "ecs_cluster_name" {}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "private_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "public_subnet_cidrs" {
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}
variable "azs" {
  default = ["us-east-2a", "us-east-2b"]
}
variable "elb-name" {}
variable "target_group_port" {}
variable "repository_name" {}
variable "execution_role" {}
variable "project_name" {}
variable "github_owner" {}
variable "frontend_repo" {}
variable "frontend_branch" {}
variable "backend_repo" {}
variable "backend_branch" {}


################################################## Route 53 Zone ##########################################################

resource "aws_route53_zone" "example" {
  name = var.route53_zone_name # Replace with your domain name
  tags = local.common_tags

}

################################################## ACM ##########################################################

module "acm_cert" {
  source          = "./modules/acm"
  domain_name     = var.acm_cert_domain_name
  route53_zone_id = aws_route53_zone.example.zone_id
  tags            = local.common_tags

}
#################################################### S3 Bucket ###########################################################

module "S3_Frontend" {
  source      = "./modules/s3_hosting"
  bucket_name = var.cloudfront_s3_bucket_name
  tags        = local.common_tags

}

################################################## CloudFront ####################################################################

module "cloudfront" {
  source              = "./modules/cloudfront"
  s3_bucket_domain    = module.S3_Frontend.s3_domain_name
  s3_bucket_name      = module.S3_Frontend.s3_bucket_name
  domain_name         = var.cloudfront_domain_name
  depends_on          = [module.S3_Frontend]
  acm_certificate_arn = module.acm_cert.acm_certificate_arn
  alias               = var.cloudfront_alias
  tags                = local.common_tags

}


################################################## Route 53 ##########################################################
module "route53" {
  source = "./modules/route_53"

  domain_name            = var.route53_domain_name
  record_name            = var.route53_record_name
  alias_name             = module.cloudfront.cloudfront_domain_name
  alias_zone_id          = module.cloudfront.cloudfront_hosted_zone_id
  evaluate_target_health = true # Or false, depending on your use case
  tags                   = local.common_tags

}
################################################## VPC #################################################################

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  tags                 = local.common_tags

}
################################################## Security Group ##################################################################

module "RDS_SG" {
  source  = "./modules/security_group"
  vpc_id  = module.vpc.vpc_id
  sg_name = "RDS-SG"
  ingress = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] # Allow only internal access (could be adjusted)
    }
  ]
  tags = local.common_tags

}

#################################################### Security Group (ALB) ###########################################################

module "ALB_SG" {
  source  = "./modules/security_group"
  vpc_id  = module.vpc.vpc_id
  sg_name = "ALB-SG"
  ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = local.common_tags

}

#####################################################  Load Balancer ################################################################

module "ALB" {
  source                = "./modules/load_balancer"
  elb-name              = var.elb-name
  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.public_subnet_ids
  security_groups       = [module.ALB_SG.SG_id]
  target_group_name     = "Backend"
  target_group_port     = var.target_group_port
  target_group_protocol = "HTTP"
  listener_port         = "443"
  listener_protocol     = "HTTPS"
  health_check_path     = "/api/health"
  health_check_interval = 120
  unhealthy_threshold   = 3
  listener_cert_arn     = module.acm_cert.acm_certificate_arn
  tags                  = local.common_tags

}

################################################## ECR (Private Repo) ######################################################

module "ecr" {
  source               = "./modules/ecr" # path to the module directory
  repository_name      = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  tags                 = local.common_tags

}


################################################## Task Definition(Backend) ######################################################

module "ecs_task_def_backend" {
  source             = "./modules/ecs_task_definition"
  task_name          = "Backend"
  docker_image       = module.ecr.repository_arn
  execution_role     = "arn:aws:iam::851725420958:role/ECSTaskExecutionRole"
  container_name     = "backend"
  container_port     = 3000
  host_port          = 3000
  container_portname = "backend"
  cpu_units          = 1024
  memory             = 2048
  environment_vars = [
    {
      name  = "SPRING_PROFILES_ACTIVE"
      value = "test"
    }
  ]
  secrets = [

    {
      name = "jwt" // Environment variable name in your container
      value_from = {
        secret_manager_secret_version = var.jwt_token_parameter_arn
      }
    },
    {
      name = "db_host" // Environment variable name in your container
      value_from = {
        secret_manager_secret_version = var.db_hostname_arn
      }
    },
    {
      name = "db_username" // Environment variable name in your container
      value_from = {
        secret_manager_secret_version = var.db_username_arn
      }
    },
    {
      name = "db_password" // Environment variable name in your container
      value_from = {
        secret_manager_secret_version = var.db_password_arn
      }
    }

  ]
  tags = local.common_tags

}

######################################################## ECS Cluster #############################################################

module "ecs_cluster" {
  source         = "./modules/ecs_cluster"
  cluster_name   = var.ecs_cluster_name
  execution_role = var.execution_role
  tags           = local.common_tags

}

############################################### Security Group (Backend Service) #################################################

module "backend_SG" {
  source  = "./modules/security_group"
  vpc_id  = module.vpc.vpc_id
  sg_name = "Backend-SG"
  ingress = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
  tags = local.common_tags

}

#################################################### ECS Service (Backend) ########################################################

module "ecs_backend" {
  source                 = "./modules/ecs_service"
  service_name           = "Backend"
  #ecs_namespace          = resource.aws_service_discovery_http_namespace.ecs_namespace.name
  cluster_arn            = module.ecs_cluster.cluster_arn
  task_def_arn           = module.ecs_task_def_backend.task_def_arn
  desired_count          = 1
  container_portname     = "backend"
  dns_name               = "backend"
  proxy_port             = 8080
  subnets                = module.vpc.public_subnet_ids
  security_groups        = [module.backend_SG.SG_id]
  loadblancer_required   = true
  service_connect_enable = true
  target_group_arn       = module.ALB.target_group_arn
  container_name         = "backend"
  container_port         = 3000
  tags                   = local.common_tags

}

################################################## Bastion Host ##########################################################

module "bastion_host" {
  source                = "./modules/bastion_host"
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.vpc.public_subnet_ids[0] # Use one of the public subnets from the VPC module
  key_pair              = "bastion-key-pair"
  bastion_instance_type = "t2.micro"
  bastion_ami           = "ami-037774efca2da0726" # Replace with your region-specific AMI ID
  bastion_name          = "my_bastion_host"
  tags                  = local.common_tags

}

################################################## S3- State file bucket ##########################################################
# module "s3_state_bucket" {
#   source      = "./modules/s3"            # Path to the module directory
#   bucket_name = "tf-infra-state-bucket" # Replace with your bucket name
#   tags        = local.common_tags
# }

# # Resource to add bucket policy to a bucket 
# resource "aws_s3_bucket_policy" "public_read_access" {
#   bucket = module.s3_state_bucket.bucket_name  # Use the output from the module
#   policy = data.aws_iam_policy_document.public_read_access.json
# }

# # DataSource to generate a policy document
# data "aws_iam_policy_document" "public_read_access" {
#   statement {
#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     actions = [
#       "s3:GetObject",
#       "s3:ListBucket",
#     ]

#     resources = [
#       module.s3_state_bucket.bucket_arn,         # Reference bucket ARN from the module
#       "${module.s3_state_bucket.bucket_arn}/*",  # Reference bucket ARN with wildcard
#     ]
#   }
# }

# terraform {
#   backend "s3" {
#     bucket = "tf-infra-state-bucket"
#     key    = "proj1/terraform.tfstate"   # Store state file in respective directory
#     region = "us-east-2"                 # Replace with your bucket's region
#   }
# }


################################################# S3 - App user ##########################################################

module "s3_app" {
  source      = "./modules/s3"     # Path to the module directory
  bucket_name = "app-user" # Replace with your bucket name
  tags        = local.common_tags

}

################################################# S3 - App user ##########################################################

module "s3_artifact" {
  source      = "./modules/s3"            # Path to the module directory
  bucket_name = "artifact-bucket" # Replace with your bucket name
  tags        = local.common_tags

}

################################################## Codestar Connection ##########################################################

resource "aws_codestarconnections_connection" "codestar_connection" {
  name          = "github-connection"
  provider_type = "GitHub"
  tags          = local.common_tags

}

################################################## CodeBuild Service Role #####################################################


data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_project_role" {
  name               = "codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  description = "A policy for codebuild to write to cloudwatch, s3, and access SSM"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "cloudwatch:*",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action" = [
          "s3:Get*",
          "s3:PutBucketVersioning",
          "s3:List*",
          "s3:UpdateObject",
          "s3:PutEncryptionConfiguration",
          "s3:PutObject",
          "s3:PutBucketPublicAccessBlock",
          "s3:CreateBucket"
        ]
        "Effect"   = "Allow"
        "Resource": [
        "arn:aws:s3:::${module.s3_artifact.bucket_name}", // The bucket itself
        "arn:aws:s3:::${module.s3_artifact.bucket_name}/*", // All objects in the bucket
        "arn:aws:s3:::${module.S3_Frontend.s3_bucket_name}", // The bucket itself
        "arn:aws:s3:::${module.S3_Frontend.s3_bucket_name}/*" // All objects in the bucket
      ]
      },
      {
        Action = [
          "ecs:CreateCluster",
          "ecs:CreateService",
          "ecs:DeleteCluster",
          "ecs:DeleteService",
          "ecs:DeregisterTaskDefinition",
          "ecs:Describe*",
          "ecs:PutClusterCapacityProviders",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateCluster",
          "ecs:UpdateService",
          "ecs:TagResource"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:DescribeRepositories",
          "ecr:CreateRepository",
          "ecr:ListTagsForResource",
          "ecr:TagResource",
          "ecr:SetRepositoryPolicy",
          "ecr:GetRepositoryPolicy",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        "Action": [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/path/*"
        ]
      },
      {
        "Action": [
          "cloudfront:CreateInvalidation",
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_project_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

####################################### CodePipeline Role #######################################

resource "aws_iam_role" "codepipeline_role" {
  name = "appexample-dev-codepipeline-role"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codepipeline.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "codepipeline_execution_policy" {
  name        = "codepipeline-policy"
  description = "A policy with permissions for codepipeline to start builds, access SSM, CloudWatch, and S3"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["codebuild:StartBuild", "codebuild:BatchGetBuilds"],
        "Resource": "*"
      },{
        Effect = "Allow"
        Action = [
          "codestar-connections:PassConnection",
          "codestar-connections:UseConnection"
        ]
        Resource = "codestar_connection_arn"
      },
      {
        "Effect": "Allow",
        "Action": ["cloudwatch:*"],
        "Resource": "*"
      },
      {
        "Action" = [
          "s3:Get*",
          "s3:PutBucketVersioning",
          "s3:List*",
          "s3:UpdateObject",
          "s3:PutEncryptionConfiguration",
          "s3:PutObject",
          "s3:PutBucketPublicAccessBlock",
          "s3:CreateBucket"
        ]
        "Effect"   = "Allow"
        "Resource" = "arn:aws:s3:::${module.s3_artifact.bucket_name}/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        "Resource": [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/path/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_execution_policy.arn
}

####################################### ECS Task Role #######################################

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = "appexample-dev-ecs-task-policy"
  description = "A policy for ECS task role to access S3, CloudWatch, SSM, ECR, and Secrets Manager"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::app-user",
          "arn:aws:s3:::app-user/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        "Resource": [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/path/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}


################################################## CodeBuild Project ##########################################################

module "codebuild" {
  source = "./modules/codebuild"

  project_name     = "${var.project_name}-codebuild"
  build_timeout    = 60
  service_role_arn = resource.aws_iam_role.codebuild_project_role.arn
  tags             = local.common_tags
  cloudwatch_logs_group = "Proj-1"

}

################################################## Frontned CodePipeline ##########################################################


module "frontend_pipeline" {
  source                  = "./modules/codepipeline"
  pipeline_name                    = "frontend-pipeline"
  codebuild_project_name  = module.codebuild.codebuild_project_name
  codepipeline_role_arn        = resource.aws_iam_role.codepipeline_role.arn
  codestar_connection_arn = resource.aws_codestarconnections_connection.codestar_connection.arn
  github_owner            = var.github_owner
  repo                    = var.frontend_repo
  repo_branch             = var.frontend_branch
  s3_name                 = module.S3_Frontend.s3_bucket_name
  artifact_bucket         = module.s3_artifact.bucket_arn
  cloudfront_distribution = module.cloudfront.cloudfront_distribution_id
  pipeline_type           = "frontend"
  tags                    = local.common_tags

}

################################################## Backend CodePipeline ##########################################################


module "backend_pipeline" {
  source                  = "./modules/codepipeline"
  pipeline_name           = "backend-pipeline"
  codepipeline_role_arn       = resource.aws_iam_role.codepipeline_role.arn
  codebuild_project_name  = module.codebuild.codebuild_project_name
  codestar_connection_arn = resource.aws_codestarconnections_connection.codestar_connection.arn
  github_owner            = var.github_owner
  repo                    = var.backend_repo
  repo_branch             = var.backend_branch
  ecr_uri                 = module.ecr.repository_url
  ecr_region              = "us-east-2"
  ecs_cluster_name        = module.ecs_cluster.cluster_name
  ecs_service_name        = module.ecs_backend.ecs_service_name
  artifact_bucket         = module.s3_artifact.bucket_arn
  pipeline_type           = "backend"
  tags                    = local.common_tags

}


















