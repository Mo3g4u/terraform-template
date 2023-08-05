variable "project" {
  description = "project"
  type        = string
}
variable "env" {
  description = "env"
  type        = string
}

variable "availability_zones" {
  description = "availability zones"
  type        = list(string)
  default     = ["ap-northeast-1c", "ap-northeast-1d"]
}
