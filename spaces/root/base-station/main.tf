#: GENERATED
#: BASE STATION is the remote setup for managing our space/environments
locals {
  space = {
    name       = "root",
    account_id = "ROOTROOTROOT",
    region     = "us-east-1",
  }
  root = {
    account_id = "ROOTROOTROOT",
    region     = "us-east-1",
  }
}

# Setup state in the root account
module "state" {
  source = "../../modules/remote-state"
  name   = local.space.name
  region = local.space.region
}
