output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_security_group_id" {
  value = aws_security_group.public.id
}
output "private_security_group_id" {
  value = aws_security_group.private.id
}
output "isolated_security_group_id" {
  value = aws_security_group.isolated.id
}
output "public_subnet_ids" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}
output "private_subnet_ids" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}
output "isolated_subnet_ids" {
  value = [aws_subnet.isolated1.id, aws_subnet.isolated2.id]
}
