variable "task_name" {
  type = string
  nullable = false
}

variable "execution_role" {
  type = string
  description = "ARN of the Role to be assigned to the container"
}

variable "container_name" {
    type = string
    description = "Name of the container in a given ecs task"
}

variable "docker_image" {
  type = string
  description = "Full docker image name with hostname, repo name and tag"
}

variable "cpu_units" {
  default = 256
  type = number
  description = "Fargate CPU units"
}

variable "memory" {
  default = 1024
  type = number
  description = "Fargate memory"
}

variable "host_port" {
    nullable = true
    type = number
}

variable "container_port" {
    nullable = false
    type = number
    default = 80
}

variable "container_portname" {
  type = string
  nullable = false
}

variable "environment_vars" {
  
}

variable "cloudwatch_group" {
  type = string
  nullable = true
  default = null 
}

# variable "jwt_token_parameter_arn" {
#   description = "The ARN of the JWT token stored in Parameter Store"
#   type        = string
# }

# variable "db_hostname_arn" {
#   description = "The ARN of DB Host in the parameter store"
#   type = string
  
# }

# variable "db_username_arn" {
#   description = "The ARN of DB Username in the parameter store"
#   type = string 
# }

# variable "db_password_arn" {
#   description = "The ARN of DB Password in the parameter store"
#   type = string
# }

variable "secrets" {
  type = list(object({
    name      = string
    value_from = object({
      secret_manager_secret_version = string
    })
  }))
}

variable "tags" {}
