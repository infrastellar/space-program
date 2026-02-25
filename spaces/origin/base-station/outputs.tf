#: GENERATED
#: BASE STATION is the remote setup for managing our space/environments
output "config" {
  value = {
    region       = module.state.region
    bucket       = module.state.bucket.id
    kms_key_id   = module.state.kms_alias.arn
    encrypt      = true
    use_lockfile = true
    role_arn     = module.state.role_arn
  }
}
