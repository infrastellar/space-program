variable "name" {
  type = string

  validation {
    condition     = var.name != "" && lower(var.name) == var.name
    error_message = "Names must be defined and contain all lower case characters."
  }
}

variable "region" {
  type = string
}

variable "overseer" {
  type = map(string)
  default = {
    path_prefix = "/aws-reserved/sso.amazonaws.com/"
    name_regex  = "AWSReservedSSO_SomethingOverseer_.*"
  }
}

variable "log_bucket_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

locals {
  # roles live at /platform/space/DebtBookState<spaceName>
  role_name      = format("State%s", title(var.name))
  kms_key_name   = format("%s-state-key", var.name)
  kms_key_alias  = format("alias/%s-state", var.name)
  s3_bucket_name = format("%s-state", var.name)
  policy_name    = format("%s-state", var.name)

  env_title = title(var.name)

  tags = merge(var.tags, {
    "space:name"    = var.name
    "space:region"  = var.region
    "infra:version" = "1"
  })
}
