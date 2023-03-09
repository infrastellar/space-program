mission = {
  name       = "apollo"
  tier       = "production"
  region     = "us-west-2"
  space_name = "mar"
  space_remote = {
    bucket         = ""
    dynamodb_table = ""
    encrypt        = true
    kms_key_id     = ""
    region         = "us-east-2"
  }
}

cloud_provider = {
  account_id = ""
}

mission_tags = {
  purpose = "prod"
}
