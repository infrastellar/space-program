## MISSION VARIABLES

# Mission specific configuration is contained in a single object to make it
# easy to share with mission stage procedures.
variable "mission" {
  type = object({
    name       = string
    tier       = string
    mode       = string
    region     = string
    space_name = string
    space_remote = object({
      bucket         = string
      dynamodb_table = string
      encrypt        = bool
      kms_key_id     = string
      region         = string
    })
  })

  # Defaults are set but most fail validation
  default = {
    name       = "apollo"
    tier       = "development"
    mode       = "managed"
    region     = ""
    space_name = ""
    space_remote = {
      bucket         = ""
      dynamodb_table = ""
      encrypt        = true
      kms_key_id     = ""
      region         = ""
    }
  }

  validation {
    condition     = var.mission.name != "" && lower(var.mission.name) == var.mission.name
    error_message = "Mission names must be defined and contain all lower case characters."
  }

  validation {
    condition     = var.mission.region != ""
    error_message = "Mission region must be defined."
  }

  validation {
    condition     = contains(["managed", "unmanaged", "build"], var.mission.mode)
    error_message = "Mission mode only supports three options: \"managed\", \"unmanaged\", \"build\""
  }

  validation {
    condition     = var.mission.space_remote.bucket != ""
    error_message = "Space remote bucket must be defined."
  }

  validation {
    condition     = var.mission.space_remote.dynamodb_table != ""
    error_message = "Space remote dynamodb_table must be defined."
  }

  validation {
    condition     = var.mission.space_remote.kms_key_id != ""
    error_message = "Space remote kms_key_id must be defined."
  }

  validation {
    condition     = var.mission.space_remote.region != ""
    error_message = "Space remote region must be defined."
  }
}

# Cloud provider specific configs are defined here. They are contained in a
# single object to make them easier to share with mission stage procedures.
variable "cloud_provider" {
  type = object({
    account_id = string
  })
}

# Specific mission tags can be added here
variable "mission_tags" {
  type    = object
  default = {}
}

# Locals allows there to be a manicured interface into the mission, the stages,
# and the procedures. All mission variables are represented here in locals. In
# most cases all procedures should be using the local declaration of the
# variables and not the variables themselves.
locals {
  mission        = var.mission
  cloud_provider = var.cloud_provider
  # Set default mission tags using the mission configuration
  mission_tags = merge(var.mission_tags, {
    mission_name   = var.mission.name,
    mission_tier   = var.mission.tier,
    mission_mode   = var.mission.mode,
    mission_region = var.mission.region,
    managed_by     = "terraform"
  })

  # Use this to prefix all resource names
  mission_prefix = format("%s-%s", var.mission.space_name, var.mission.name)
}

## MISSION PROVIDERS

# Default provider used for all space remote state access
# Space remote state can have it's own region, notice the region variable
provider "aws" {
  region = var.mission.space_remote.region
  assume_role {
    role_arn     = var.mission.space_remote.role_arn
    session_name = uuid()
  }
}

# Mission provider, used to manage provider resources
# This provider can operate in a separate region to the space remote state
provider "aws" {
  alias  = "mission"
  region = var.mission.region
  # profile = ...
  # other configuration here
}

## MISSION TERRAFORM

terraform {
  required_version = ">= 1.4.0"

  # Backend configuration is managed on a per space basis in <space>.s3.tfbackend
  # This remains an empty block
  backend "s3" {}

  # This will be filled in over time as new providers are used in the mission
  # stage procedures.
  required_providers {}
}
