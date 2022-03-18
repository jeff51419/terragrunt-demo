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
  source = "${get_terragrunt_dir()}/../../../../../../terraform/module//vpc"
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name                  = "stp-vpc-${local.aws_project}"
  vpc_cidr              = "10.101.0.0/16"
  vpc_pri_subnets       = ["10.101.0.0/24","10.101.10.0/24","10.101.20.0/24"]
  vpc_pub_subnets       = ["10.101.1.0/24","10.101.2.0/24","10.101.3.0/24"]
  vpc_database_subnets  = ["10.101.100.0/24","10.101.110.0/24","10.101.120.0/24"]
  create_database_subnet_group = false
  enable_nat_gateway    = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  
  # for allocate EIPs manually
  # ["eipalloc-xxxxxxxxxxxxxxxxx","eipalloc-xxxxxxxxxxxxxxxxx"]
  # vpc_backend_nat_eip_ids = []
  project               = "${local.aws_project}"
  environment           = "${local.env}"
  region                = "${local.aws_region}"
}