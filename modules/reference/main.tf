# Module: Reference
#
# This module allows reference to other terraform state files within a
# mission. When used the reference module pulls in all of the outputs provided
# by the referenced procedure and makes them available at the "state"
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

# Check to ensure our state is in the correct account, currently configured as
# a default in the variable "state_account_id"

# First we get our current caller identity so we can get the account_id
data "aws_caller_identity" "current" {}

# Second we assert that it is the correct value.
# NOTE: That checks allow data sources to be called within them but this makes
# plans very noisy, so we do the call outside of the check block and then
# assert it here.
check "state_account" {
  assert {
    condition = data.aws_caller_identity.current.account_id == var.state_account_id
    error_message = format(
      "Reference module must use the following account for state: %s (Currently: %s)",
      var.state_account_id,
      data.aws_caller_identity.current.account_id
    )
  }
}

# Create the data source to retrieve the procedure state. Most of the heavy
# lifting is done in variables.tf
data "terraform_remote_state" "state" {
  backend = var.backend
  config  = local.remote
}
