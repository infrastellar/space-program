locals {
  region = "us-east-2"
}

module "state" {
  source = "../modules/state"

  name   = "jan"
  region = local.region
}
