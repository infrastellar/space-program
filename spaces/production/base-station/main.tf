#: GENERATED
#: BASE STATION is the remote setup for managing our space/environments
locals {
  space = {
    name       = "production",
    account_id = "PRODACCTID",
    region     = "us-east-1",
  }
  root = {
    account_id = "ROOTACCTID",
    region     = "us-east-1",
  }
}

# Setup state in the root account
module "state" {
  source = "../../modules/remote-state"
  name   = local.space.name
  region = local.space.region
}
