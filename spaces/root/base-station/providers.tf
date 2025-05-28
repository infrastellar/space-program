#: GENERATED
#: BASE STATION is the remote setup for managing our space/environments

# AWS Provider for working with Root Account resources
provider "aws" {
  region              = local.root.region
  allowed_account_ids = [local.root.account_id]
}
