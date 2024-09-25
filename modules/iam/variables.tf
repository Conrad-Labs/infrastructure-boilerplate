variable "ecs_task_role_name" {
  default = "ecs-task-role"
}

variable "ecs_execution_role_name" {
  default = "ecs-task-execution-role"
}

variable "codepipeline_role_name" {
  default = "codepipeline-role"
}

variable "codebuild_role_name" {
  default = "codebuild-role"
}

variable "tags" {}
