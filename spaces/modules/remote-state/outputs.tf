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

output "region" {
  value = data.aws_region.current.name
}

output "role_arn" {
  value = aws_iam_role.state.arn
}

output "tfbackend" {
  value = templatefile(
    "${path.module}/tfbackend.tmpl",
    {
      bucket       = aws_s3_bucket.state.id
      kms_key_id   = aws_kms_alias.state.arn
      encrypt      = true
      use_lockfile = true
      region       = var.region
    }
  )
}
