variable "api_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  type        = string
}

variable "throttle_burst_limit" {
  type        = number
  default     = 500
}

variable "throttle_rate_limit" {
  type        = number
  default     = 100
}

variable "quota_limit" {
  type        = number
  default     = 1000000
}

variable "require_api_key" {
  type        = bool
  default     = false
}

variable "log_retention_days" {
  type        = number
  default     = 1
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "destroy" {
  type    = bool
  default = false
}