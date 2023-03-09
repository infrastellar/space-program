locals {
  region = "us-east-2"
}

module "state" {
  source = "../modules/state"

  name       = "mar"
  region     = local.region
  account_id = ""
}
