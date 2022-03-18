locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env              = local.environment_vars.locals.environment
  aws_profile      = local.account_vars.locals.aws_profile
  aws_region       = local.region_vars.locals.aws_region
  aws_assume_role  = local.account_vars.locals.aws_assume_role

  role_numbers     = regex("[0-9]+", local.aws_assume_role)
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
# git@github.com:terraform-aws-modules/terraform-aws-vpc.git

terraform {
  source = "${get_terragrunt_dir()}/../../../../../../terraform/module//kms"
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  description  = "encrypt cloudwatch"
  multi_region = true
  alias        = "kms-cloudwatch"

  region       = "${local.aws_region}"
  role_numbers = "${local.role_numbers}"
}
