# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load environment-level variables
  environment_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load project-level variables
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  
  # Extract the variables we need for easy access
  env             = local.environment_vars.locals.environment
  aws_region      = local.region_vars.locals.aws_region
  short_region    = local.region_vars.locals.short_region
  account_name    = local.account_vars.locals.account_name
  aws_profile     = local.account_vars.locals.aws_profile
  aws_assume_role = local.account_vars.locals.aws_assume_role
  aws_project     = local.project_vars.locals.aws_project
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]

  # Only these AWS Account IDs may be operated on by this template
  profile                 = "${local.aws_profile}"
  region                  = "${local.aws_region}"
  # access_key = "$ACCESS_KEY"
  # secret_key = "$SECRET_KEY"
  assume_role {
    role_arn = "${local.aws_assume_role}"
  }
}
provider "random" {
}
EOF
}
# Configure root level variables that all resources can inherit
terraform {
  before_hook "checkov" {
    commands = ["plan"]
    execute = [
      "checkov",
      "-d",
      ".",
      # "--quiet",
      "--framework",
      "terraform",
    ]
    run_on_error = true
  }
  before_hook "terrascan" {
    commands = ["plan"]
    execute = [
      "terrascan",
      "scan",
      "--iac-dir",
      ".",
      "--iac-type",
      "terraform",
      "--use-colors",
      "t",
      "--policy-type",
      "aws",
      "--non-recursive",
      "--verbose",
      "--skip-rules",
      "AC_AWS_0369"
    ]
    run_on_error = true
  }
  before_hook "tfsec" {
    commands = ["plan"]
    execute = [
      "tfsec",
      ".",
      "--exclude-downloaded-modules",
    ]
    run_on_error = true
  }
  extra_arguments "common_vars" {
    commands = [
      "init",
      "apply",
      "plan",
      "import",
      "push",
      "refresh"
    ]

    arguments = [
      "-var-file=${get_terragrunt_dir()}/../common.tfvars"
    ]
  }
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.account_name}-${local.short_region}-${local.env}-${local.aws_project}-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    profile        = local.aws_profile
    # access_key = "$TPERD_ACCESS_KEY"
    # secret_key = "$TPERD_SECRET_KEY"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "version" {
  path = "version.tf"
  if_exists = "overwrite"
  contents = <<EOT
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version   = ">= 4.6.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.1.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.1.0"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "2.19.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.1.2"
    }
    kustomization = {
      source = "kbst/kustomization"
      version = "0.7.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.2"
    }  
  }
}
EOT
}