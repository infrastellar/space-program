variable "namespace" {
  type = string
}

variable "secret" {
  type = string
}

locals {
  # See modules/form-secret, this should match that path exactly
  namespec = "%s/%s"
  name     = format(local.namespec, var.namespace, var.secret)
}
