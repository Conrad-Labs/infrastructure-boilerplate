variable "service_name" {
  type = string
  nullable = false
}

variable "cluster_arn" {
  type = string
  nullable = false
}

variable "task_def_arn" {
  type = string
  nullable = false
}

variable "desired_count" {
  type = number
  nullable = false
}

# variable "ecs_namespace" {
#   type = string
#   nullable = true
#   default = null
# }

variable "container_portname" {
  type = string
  nullable = true
  default = null
}

variable "dns_name" {
  type = string
  nullable = true
  default = null
}

variable "proxy_port" {
  type = number
  nullable = true
  default = 0
}

variable "subnets" {
  type = list(string)
  nullable = false
}

variable "security_groups" {
  type = list(string)
  nullable = false
}

variable "loadblancer_required" {
  type = bool
  nullable = false 
}


variable "target_group_arn" {
  type = string
  nullable = true
  default = null
}

variable "container_name" {
  type = string  
}

variable "container_port" {
  type = number
  nullable = true
  default = 0
}

# variable "service_connect_enable" {
#   type = bool
#   nullable = false
# }

variable "tags" {}
