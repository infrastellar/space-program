data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_roles" "overseer" {
  name_regex  = var.overseer.name_regex
  path_prefix = var.overseer.path_prefix
}

resource "random_string" "uniq" {
  length  = 6
  special = false
  upper   = false
}

#### STATE ROLE
resource "aws_iam_role" "state" {
  name = local.role_name
  path = "/platform/space/"

  assume_role_policy = data.aws_iam_policy_document.state_role.json
}

data "aws_iam_policy_document" "state_role" {
  statement {
    sid    = "InfraStateAllowAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "AWS"
      identifiers = data.aws_iam_roles.overseer.arns
    }
  }
}

#### RESOURCES

resource "aws_kms_key" "state" {
  description             = format("KMS key used for %s remote state bucket", var.name)
  deletion_window_in_days = 20
  enable_key_rotation     = true

  tags = merge(local.tags, {
    "Name" = local.kms_key_name
  })

  # This policy gives permissions for administration on this key to the root
  # account and the controller user
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Enable IAM Role Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow use of the key",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "${aws_iam_role.state.arn}"
          ]
        },
        "Action": [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:TagResource"
        ],
        "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_kms_alias" "state" {
  name          = local.kms_key_alias
  target_key_id = aws_kms_key.state.key_id
}

resource "aws_s3_bucket" "state" {
  bucket = format("%s-%s", local.s3_bucket_name, random_string.uniq.result)
  tags = merge(local.tags, {
    "debtbook:env:backup" = "root"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "bucket" {
  bucket = aws_s3_bucket.state.id

  target_bucket = var.log_bucket_id
  target_prefix = local.s3_bucket_name
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

#### POLICIES

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "PutObjPolicy",
    "Statement": [
        {
            "Sid": "DenyIncorrectEncryptionHeader",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.state.arn}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "aws:kms"
                }
            }
        },
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.state.arn}/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        },
        {
            "Sid": "RestrictKMSKeyEncryptionAccess",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.state.arn}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption-aws-kms-key-id": "${aws_kms_key.state.arn}"
                }
            }
        },
        {
            "Sid": "DenyHTTPRequests",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "*",
            "Resource": "${aws_s3_bucket.state.arn}/*",
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "state" {
  role       = aws_iam_role.state.name
  policy_arn = aws_iam_policy.state.arn
}

resource "aws_iam_policy" "state" {
  name   = local.policy_name
  policy = data.aws_iam_policy_document.state.json
}

data "aws_iam_policy_document" "state" {
  statement {
    sid    = format("%sAllowListBucket", local.env_title)
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.state.arn
    ]
  }

  statement {
    sid    = format("%sAllowEditingBucketObjects", local.env_title)
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersion",
      "s3:PutObjectTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging",
      "s3:DeleteObject",
      "s3:ListObject"
    ]
    resources = [
      "${aws_s3_bucket.state.arn}",
      "${aws_s3_bucket.state.arn}/*"
    ]
  }

  statement {
    sid    = format("%sAllowEncryptDecryptStateKey", local.env_title)
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = [aws_kms_key.state.arn]
  }
}
