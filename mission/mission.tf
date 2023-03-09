## MISSION VARIABLES

variable "mission" {
  type = object({
    name = string
    tier = string
    mode = string
  })
}

variable "provider" {
  type = object({
    region     = string
    account_id = string
  })
}

variable "remote_config" {
  type = object({
    bucket         = string
    dynamodb_table = string
    encrypt        = bool
    kms_key_id     = string
    region         = string
  })
}

variable "mission_tags" {
  type = object({
    managed_by = string
  })
  default = {
    managed_by = "terraform"
  }
}

locals {
  tags = merge(var.mission_tags, {
    mission_name = var.mission.name
    mission_tier = var.mission.tier
    mission_mode = var.mission.mode
  })
}

## MISSION PROVIDERS

## MISSION TERRAFORM

terraform {
  required_version = ">= 1.4.0"

  # Backend configuration is managed on a per space basis in <space>.s3.tfbackend
  backend "s3" {}

  required_providers {}
}
