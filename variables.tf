variable "region" {
  description = "AWS region"
  default     = "ap-northeast-1"
  type        = string
}

variable "project" {
  description = "project name"
  default     = "terraform-template"
  type        = string
}

variable "env" {
  description = "environment type"
  default     = "dev"
  type        = string
}

variable "availability_zones" {
  description = "availability zones"
  default     = ["ap-northeast-1c", "ap-northeast-1d"]
  type        = list(string)
}

