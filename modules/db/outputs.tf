output "mysql_secret_arn" {
  description = "mysql secret arn"
  value       = aws_secretsmanager_secret.rds.arn
}
