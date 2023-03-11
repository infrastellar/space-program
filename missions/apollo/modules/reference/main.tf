# Module: Reference
#
# This module allows reference to other terraform state files within the
# mission. When used the reference module pulls in all of the outputs provided
# by the referenced to procedure and makes them available at the "state"
# output.
#
# Example of pulling in state from another procedure:
#
#   module "procedure_name" {
#     source    = "../../modules/reference"
#     mission   = var.mission
#     stage     = var.stage
#     procedure = "procedure-name"
#   }
#
# Example of using the module outputs:
#
#   config = module.procedure_name.state.(output_defined_in_procedure)

# Create the data source to retrieve the procedure state. Most of the heavy
# lifting is done in variables.tf
data "terraform_remote_state" "state" {
  backend = var.backend
  config  = local.remote
}
