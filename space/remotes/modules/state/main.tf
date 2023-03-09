data "aws_caller_identity" "current" {}

resource "random_string" "uniq" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_iam_group" "state" {
  name = local.group_name
}

data "aws_iam_policy_document" "state_group" {
  statement {
    sid    = "AllowStateGroupRoleAccess"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.state.arn
    ]
  }
}

resource "aws_iam_policy" "state_group" {
  name        = format("%s-group-assume-state-role", var.name)
  description = format("Allow users in %s group to assume state role for %s environment", aws_iam_group.state.name, var.name)
  policy      = data.aws_iam_policy_document.state_group.json
}

resource "aws_iam_group_policy_attachment" "state_group" {
  group      = aws_iam_group.state.name
  policy_arn = aws_iam_policy.state_group.arn
}


#### STATE ROLE
# Not sure yet if this is needed
resource "aws_iam_role" "state" {
  name = local.role_name

  assume_role_policy = data.aws_iam_policy_document.state_role.json
}

data "aws_iam_policy_document" "state_role" {
  statement {
    sid    = "AllowAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "AWS"
      identifiers = [
        format("arn:aws:iam::%s:root", var.account_id)
      ]
    }
  }
}

#### RESOURCES

resource "aws_dynamodb_table" "state" {
  name           = local.dynamodb_table_name
  read_capacity  = 3
  write_capacity = 3
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    "Name" = local.dynamodb_table_name
  }
}

resource "aws_kms_key" "state" {
  description             = format("KMS key used for %s remote state bucket", var.name)
  deletion_window_in_days = 20
  enable_key_rotation     = true

  tags = {
    "Name" = local.kms_key_name
  }

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
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "${aws_iam_role.state.arn}"
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

resource "aws_s3_bucket_acl" "state" {
  bucket = aws_s3_bucket.state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

#### POLICIES

resource "aws_iam_policy" "locks" {
  name   = local.dynamodb_table_name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "ListAndDescribe",
          "Effect": "Allow",
          "Action": [
            "dynamodb:List*",
            "dynamodb:DescribeReservedCapacity*",
            "dynamodb:DescribeLimits",
            "dynamodb:CreateTable",
            "dynamodb:DescribeTimeToLive",
            "dynamodb:TagResource",
            "dynamodb:DescribeTable",
            "dynamodb:DescribeContinuousBackups",
            "dynamodb:UntagResource"
          ],
          "Resource": "*"
        },
        {
          "Sid": "SpecificTable",
          "Effect": "Allow",
          "Action": [
              "dynamodb:BatchGet*",
              "dynamodb:DescribeStream",
              "dynamodb:DescribeTable",
              "dynamodb:Get*",
              "dynamodb:Query",
              "dynamodb:Scan",
              "dynamodb:BatchWrite*",
              "dynamodb:Delete*",
              "dynamodb:Update*",
              "dynamodb:PutItem"
          ],
          "Resource": "${aws_dynamodb_table.state.arn}"
        }
    ]
}
EOF
}

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
        }
    ]
  }
EOF

}

resource "aws_iam_policy" "state" {
  name   = local.s3_bucket_name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
           "Effect": "Allow",
           "Action": [
              "s3:ListBucket"
           ],
           "Resource": [
             "${aws_s3_bucket.state.arn}"
           ]
        },
        {
           "Effect": "Allow",
           "Action": [
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
           ],
           "Resource": [
              "${aws_s3_bucket.state.arn}",
              "${aws_s3_bucket.state.arn}/*"
            ]
        },
        {
           "Effect": "Allow",
           "Action": ["kms:Decrypt", "kms:Encrypt"],
           "Resource": "${aws_kms_key.state.arn}"
        }
     ]
}
EOF
}

#### POLICY ATTACHMENTS

resource "aws_iam_role_policy_attachment" "locks_policy" {
  policy_arn = aws_iam_policy.locks.arn
  role       = aws_iam_role.state.name
}

resource "aws_iam_role_policy_attachment" "state_policy" {
  policy_arn = aws_iam_policy.state.arn
  role       = aws_iam_role.state.name
}
