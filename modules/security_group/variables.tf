variable "vpc_id" {
  type = string
  nullable = false
}

variable "sg_name" {
  type = string
  nullable = false
}

variable "ingress" {
   default = [
   {
       from_port   = 80
       to_port     = 80
       description = "Port 80"
   }]
}

variable "tags" {}
