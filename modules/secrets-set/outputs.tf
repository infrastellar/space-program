output "metadata" {
  value = aws_secretsmanager_secret.secret
}

output "arn" {
  value = aws_secretsmanager_secret_version.secret.arn
}
