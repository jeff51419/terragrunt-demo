### System ###
# AWS privilege
variable "profile" {
  type    = string
  default = ""
}
variable "assume_role" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = ""
}

variable "project" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "account" {
  type    = string
  default = ""
}
# AWS account name for SQS naming prefix (for temporary)
variable "aws_account_name" {
  type    = string
  default = ""
  # AWS account name e.g., "aws-polkast", "aws-gstun", "aws-rd", "aws-tperd" ...
}

### Site information ###
variable "domain" {
  type    = string
  default = "splashtop.de"
}
## Passing outputs between modules
variable "vpc_id" {
  description = "vpc module outputs the ID under the name vpc_id"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "vpc module outputs the pub-private-subnet ID under the name subnets"
  type        = list(string)
  default     = []
}

variable "eks_bottlerocket_enabled" { # Default "true" for Create EKS
  type    = bool
  default = true
}

variable "eks_spot_enabled" { # spot instance
  type    = bool
  default = false
}

### Services name ###
variable "app_service" {
  type    = string
  default = "gh-bottlerocket"
}


### SG whitelist ###
variable "sg_whitelist_ips" {
  type = list(string)
  default = [
    #  "44.233.246.210/32",    # James gstun-ctrl
    "74.203.89.92/32",    # James office 1
    "104.128.103.242/32", # James office 2
    "75.61.103.188/32",   # SJC office 1
    "50.193.44.33/32",    # SJC office 2
    "122.224.111.100/32", # HGH office
    "211.23.144.132/32",  # TPE office 1
    "61.31.169.172/32"    # TPE office 2
  ]
}
### EKS ###
# Version
variable "k8s_version" {
  description = "k8s cluster version"
  default     = "1.20"
  type        = string
}

variable "enable_admin_container" {
  description = "Enable/disable admin container"
  default     = false
  type        = bool
}

variable "enable_control_container" {
  description = "Enable/disable control container"
  default     = true
  type        = bool
}
# Log retention
variable "eks_log_retention" { # EKS log retention day
  type    = number
  default = 7
}
# Customized AMI for EKS work node
variable "worker_ami_owner_id" { # AMI owner ID
  type    = string
  default = "867359575977"
}
variable "worker_ami_linux" { # Linux AMI name filter keywords
  type    = string
  default = "*copied from GoldenAMIBase-1.0-amazon-eks-node-1.16-noSELINUX-HFSPLUS-3"
}
### Work groups scaling ###
# Instance types of maximum pods list:
# https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
variable "node_instance_type" { # Instance type
  type    = string
  default = "t3a.xlarge"
}
variable "override_instance_types" { # Instance type
  type = list(string)
  default = [
    "t3a.xlarge",
    "t3.xlarge",
    "t2.xlarge",
    "m5a.xlarge",
    "m5.xlarge"
  ]
}

variable "node_max_size" { # Maximum size in scaling
  type    = number
  default = 5
}
variable "node_min_size" { # Minimum size in scaling
  type    = number
  default = 3
}
variable "node_desired_size" { # Desired size in scaling
  type    = number
  default = 3
}
variable "node_on_demand_size" { # On-demand size of work nodes
  type    = number
  default = 0
}


variable "ssh_keypair" { # SSH key name for EC2 instance
  type    = string
  default = ""
}

### Certificates ###
variable "certArnDomain" {
  type    = string
  default = "arn:aws:acm:eu-central-1:964543278669:certificate/22e6bdda-e82a-467a-baec-0c056972fb26"
}
variable "certArnApi" {
  type    = string
  default = "arn:aws:acm:eu-central-1:964543278669:certificate/71803539-520b-4194-aaba-96c35783dfba"
}

### RBAC ###
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "777777777777",
    "888888888888",
  ]
}
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]
}
variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]
}

variable "sonarqube_instance_types" { # Instance type
  type    = list(string)
  default = ["m5.large"]
}