variable "mission" {
  type = any

  # validation {
  #   condition     = can(var.mission.hello)
  #   error_message = "You must provide someone to say hello too"
  # }
}

locals {
  mission_defaults = {
    name = "example"
    id   = "ex"
  }
  mission = merge(local.mission_defaults, var.mission)

  mission_features = {
    example_myfeature = "false"
  }
  features = merge(local.mission_features, var.environment.features)

  enable = {
    # Method for enabling features across the mission without tying them to the
    # feature names themselves, this allows for testing of additional
    # conditions such as whether we're in production or not
    example = alltrue([lookup(var.environment.features, "example_myfeature", false)])

    # A quick way to determine region designation
    is_publisher  = var.region.status.designation == "publisher" ? true : false
    is_subscriber = var.region.status.designation == "subscriber" ? true : false
  }
}

# Manage mission documentation. Rendered documents are placed in the specific
# environments' docs folder. All that is needed is to drop a README.md into the
# procedure and it will get included. You can use template variables. All of
# the keys of the module below can be used as template variables with the
# defaults (mission_features, mission_defaults) passed to the mission README.md
module "documentation" {
  source      = "../../modules/documentation"
  module_path = path.module

  # Pass in a documentation structure from the procedure if it exists
  documentation = local.documentation

  # The following are passed to the procedure README.md templatefile function
  region      = var.region
  environment = var.environment
  mission     = local.mission  # Compiled from the mission configuration in the environment
  features    = local.features # Compiled from the environment configuration
  enable      = local.enable   # Enabled on the mission according to the environment configuration

  # The following are passed to the mission README.md templatefile function
  mission_defaults = local.mission_defaults # Mission default configurations
  mission_features = local.mission_features # Mission default features
}

# Manage providers used in the mission here
terraform {
  required_version = ">= 1.9"
  backend "s3" {}
}
