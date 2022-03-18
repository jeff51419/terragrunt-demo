locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))


  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  aws_project = local.project_vars.locals.aws_project
  aws_region  = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
# git@github.com:terraform-aws-modules/terraform-aws-vpc.git

terraform {
  source = "${get_terragrunt_dir()}/../../../../../../terraform/module//opensearch"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# Passing outputs for kms-ebs modules
dependency "kms-cloudwatch" {
  config_path = "../kms-cloudwatch"

  # it corresponds to a map that will be injected in place of the actual dependency outputs 
  # if the target config hasn’t been applied yet
  mock_outputs = {
    arn    = "fake-arn"
    key_id = "fake-key_id"
  }
  # restrict this behavior
  mock_outputs_allowed_terraform_commands = ["validate","plan","init"]
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  domain                = "opensearch"
  # elasticsearch_version = "OpenSearch_1.1" or elasticsearch_version = "7.10"
  elasticsearch_version = "OpenSearch_1.1"
  domain_acm            = "arn:aws:acm:ap-northeast-1:385284847228:certificate/c9152e6e-fb32-4b53-ab70-0c07ea3fa184"
  opensearch_domain     = "opensearch.tperd.splashtop.eu"
  domain_zone           = "tperd.splashtop.eu"
  master_user_name      = "admin"

  cloudwatch_kms        = dependency.kms-cloudwatch.outputs.arn
  # master_user_password = ""
  project               = "${local.aws_project}"
  environment           = "${local.env}"
  region                = "${local.aws_region}"
}