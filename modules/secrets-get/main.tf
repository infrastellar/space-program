data "aws_secretsmanager_secret" "secret" {
  name = local.name
}

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}
