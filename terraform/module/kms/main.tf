resource "aws_kms_key" "this" {
  description                        = var.description
  customer_master_key_spec           = var.customer_master_key_spec
  multi_region                       = var.multi_region
  enable_key_rotation                = var.enable_key_rotation
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check

  policy = <<EOT
{
  "Version" : "2012-10-17",
  "Id" : "key-default-1",
  "Statement" : [ 
    {
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${var.role_numbers}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.region}.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "*",
      "Condition": {
          "ArnEquals": {
            "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.region}:${var.role_numbers}:log-group:/aws/OpenSearchService/domains/*"
          }
      }
    }  
  ]
}

EOT
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this.key_id
}