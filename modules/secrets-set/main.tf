locals {
  # See modules/form-secret, this should match that path exactly
  namespec = "%s/%s"
  name     = format(local.namespec, var.namespace, var.secret)
}

resource "aws_secretsmanager_secret" "secret" {
  name = local.name
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.arn
  secret_string = var.value
}
