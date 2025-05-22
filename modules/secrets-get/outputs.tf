output "metadata" {
  value = data.aws_secretsmanager_secret.secret
}

output "arn" {
  value = data.aws_secretsmanager_secret_version.secret.arn
}

output "value" {
  value = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)
}
