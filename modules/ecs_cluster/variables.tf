variable "cluster_name" {
  type = string
  nullable = false
}

variable "execution_role" {
  type = string
  description = "ARN of the Role to be assigned to the container"
}

variable "tags" {}
