variable "region" {
  description = "AWS region"
  default     = "ap-northeast-1"
}

variable "project" {
  default = "terraform-template"
}

variable "env" {
  default = "dev"
}

variable "availability_zones" {
  default = ["ap-northeast-1c", "ap-northeast-1d"]
}

variable "rds_scaling_min_capacity" {
  default = 0.5
}

variable "rds_scaling_max_capacity" {
  default = 1
}
