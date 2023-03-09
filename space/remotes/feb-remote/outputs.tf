output "dynamodb_table" {
  description = "DynamoDB table for handling state locks"
  value       = module.state.dynamodb_table.name
}

output "bucket" {
  description = "S3 bucket for handling state files"
  value       = module.state.bucket.id
}

output "region" {
  value = local.region
}

output "kms_key_id" {
  description = "KMS key alias"
  value       = module.state.kms_alias.name
}

output "encrypt" {
  value = "true"
}

output "role_arn" {
  value = module.state.role.arn
}

