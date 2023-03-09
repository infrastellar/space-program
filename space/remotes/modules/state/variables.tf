variable "name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

locals {
  dynamodb_table_name = format("%s-terraform-locks", var.name)
  kms_key_name        = format("%s-terraform-key", var.name)
  kms_key_alias       = format("alias/%s", var.name)
  s3_bucket_name      = format("%s-terraform-state", var.name)
  role_name           = format("%s-terraform-state-role", var.name)
  group_name          = format("%s-infra", var.name)
}
