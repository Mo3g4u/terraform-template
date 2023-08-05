variable "project" {
  description = "project name"
  type        = string
}
variable "env" {
  description = "environment type"
  type        = string
}
variable "vpc_security_group_ids" {
  description = "security group ids"
  type        = list(string)
}
variable "subnet_ids" {
  description = "subnet ids"
  type        = list(string)
}
variable "rds_scaling_min_capacity" {
  description = "rds scaling min capacity"
  type        = number
  default     = 0.5
}
variable "rds_scaling_max_capacity" {
  description = "rds scaling max capacity"
  type        = number
  default     = 1
}
