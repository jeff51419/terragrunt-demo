# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name      = "account-1"
  aws_account_name  = "aws-account-1"
  aws_profile       = "account-1-profile"
  aws_assume_role   = "arn:aws:iam::123456789012:role/aws-account-1-admin-role"
}