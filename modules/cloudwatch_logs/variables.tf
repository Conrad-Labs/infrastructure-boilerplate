variable "log_group_name" {
  description = "The name of the CloudWatch log group"
  type        = string
}

variable "retention_in_days" {
  description = "The number of days to retain log events"
  type        = number
  default     = 14  # Set a default retention period
}

# variable "tags" {
#   description = "A map of tags to assign to the log group"
#   type        = map(string)
#   default     = {}
# }

variable "tags" {}
