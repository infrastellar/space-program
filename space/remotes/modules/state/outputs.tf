output "dynamodb_table" {
  description = "DynamoDB table for handling state locks"
  value       = aws_dynamodb_table.state
}

output "bucket" {
  description = "S3 bucket for handling state files"
  value       = aws_s3_bucket.state
}

output "kms_key" {
  description = "KMS key used to encrypt state files"
  value       = aws_kms_key.state
}

output "kms_alias" {
  description = "KMS key alias"
  value       = aws_kms_alias.state
}

output "role" {
  value = aws_iam_role.state
}
