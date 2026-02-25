variable "environment" {
  type = object({
    name = string
    tags = map(string)
  })
}

variable "mission" {
  type = string
}

variable "space" {
  type = object({
    name = string,
    config = object({
      bucket       = string
      encrypt      = bool
      use_lockfile = bool
      kms_key_id   = string
      region       = string
    })
  })
}

variable "region" {
  type = any
}

# Name of the stage (as it appears on disk: stage000)
variable "stage" {
  type    = string
  default = null
}

# Name of the procedure (as it appears on disk: procedure-name)
variable "procedure" {
  type    = string
  default = null
}

# Forward compatibility
variable "backend" {
  type    = string
  default = "s3"
}

# TODO: Use a conditional
variable "state_account_id" {
  type    = string
  default = ""
}

variable "branch" {
  type    = string
  default = "missions"
}

variable "state_path" {
  type    = string
  default = ""
}

locals {
  # STATE LOCATION: <space-remote-bucket>/missions/<mission-name>/<mission-region>/<stage>/<procedure>/terraform.tfstate
  key = var.state_path != "" ? var.state_path : format(
    "%s/%s/%s/%s/%s/%s/terraform.tfstate",
    var.environment.name,
    var.region.id,
    var.branch,
    var.mission,
    var.stage,
    var.procedure
  )

  remote = merge(var.space.config, {
    key = local.key
  })
}
