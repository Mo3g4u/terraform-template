output "vpc_id" {
  description = "vpc id"
  value       = aws_vpc.main.id
}
output "public_security_group_id" {
  description = "public security group id"
  value       = aws_security_group.public.id
}
output "private_security_group_id" {
  description = "private security group id"
  value       = aws_security_group.private.id
}
output "isolated_security_group_id" {
  description = "isolated security group id"
  value       = aws_security_group.isolated.id
}
output "public_subnet_ids" {
  description = "public subnet ids"
  value       = [aws_subnet.public1.id, aws_subnet.public2.id]
}
output "private_subnet_ids" {
  description = "private subnet ids"
  value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}
output "isolated_subnet_ids" {
  description = "isolated subnet ids"
  value       = [aws_subnet.isolated1.id, aws_subnet.isolated2.id]
}
