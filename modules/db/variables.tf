variable "project" {}
variable "env" {}
variable "vpc_security_group_ids" {}
variable "subnet_ids" {}
variable "rds_scaling_min_capacity" {
  default = 0.5
}
variable "rds_scaling_max_capacity" {
  default = 1
}
