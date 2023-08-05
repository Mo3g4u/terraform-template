variable "project" {
  description = "project name"
  type        = string
}
variable "env" {
  description = "environment type"
  type        = string
}
variable "security_group_ids" {
  description = "security group ids"
  type        = list(string)
}
variable "subnet_id" {
  description = "subnet id"
  type        = string
}
