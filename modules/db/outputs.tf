output "mysql_secret_arn" {
  value = aws_secretsmanager_secret.rds.arn
}
