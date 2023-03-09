variable "mission" {
  type = object
  validate {
    condition     = can(var.mission.space_remote)
    error_message = "Mission variable must contain a space configuration"
  }

  validate {
    condition     = can(var.mission.name)
    error_message = "Mission variable must contain a name"
  }

  validate {
    condition     = can(var.mission.region)
    error_message = "Mission variable must contain a region"
  }
}

# Name of the stage (as it appears on disk: stage000)
variable "stage" {
  type = string
}

# Name of the procedure (as it appears on disk: procedure-name)
variable "procedure" {
  type = string
}

# Forward compatibility
variable "backend" {
  type    = string
  default = "s3"
}

locals {
  key = format(
    "%s/%s/mission/%s/%s/terraform.tfstate",
    var.mission.name,
    var.mission.region,
    var.stage,
    var.procedure
  )

  remote = merge(var.mission.space_remote, {
    key = local.key
  })
}
