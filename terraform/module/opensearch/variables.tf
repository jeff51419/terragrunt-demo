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
########
variable "domain" {
  type    = string
  default = "elasticsearch"
}

variable "elasticsearch_version" {
  type    = string
  default = "OpenSearch_1.1"
}

variable "data_node_instance" {
  type    = string
  default = "r6g.large.elasticsearch"
}

variable "availability_zone_count" {
  type    = number
  description = "(Optional) Number of Availability Zones for the domain to use with zone_awareness_enabled Valid values: 2 or 3"
  default = 2
}

variable "data_node_count" {
  type    = number
  default = 2
}

variable "data_node_size" {
  type    = number
  default = 20
}

variable "master_instance_enabled" {
  type    = bool
  default = true
}

variable "master_node_instance" {
  type    = string
  default = "r6g.large.elasticsearch"
}

variable "master_node_count" {
  type    = number
  default = 3
}

variable "user_database_enabled" {
  type    = bool
  default = true
}

variable "master_user_arn" {
  type    = string
  default = ""
}

variable "master_user_name" {
  type    = string
  default = "admin"
}

variable "master_user_password" {
  type    = string
  sensitive = true
}

variable "security_group_ids" {
  description = "vpc module outputs the security group"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "vpc module outputs the pub-private-subnet ID under the name subnets"
  type        = list(string)
  default     = []
}

### whitelist ###
variable "whitelist_ips" {
  type = list(string)
  default = [
    "74.203.89.92/32",    ## James office 1
    "104.128.103.242/32", ## James office 2
    "75.61.103.188/32",   ## SJC office 1
    "50.193.44.33/32",    ## SJC office 2
    "122.224.111.100/32", ## HGH office
    "211.23.144.132/32",  ## TPE office 1
    "61.31.169.172/32"    ## TPE office 2
  ]
}


variable "domain_acm" {
  type = string
  default = "arn:aws:acm:ap-northeast-1:385284847228:certificate/c9152e6e-fb32-4b53-ab70-0c07ea3fa184"
}

variable "opensearch_domain" {
  type = string
  default = "opensearch.tperd.splashtop.eu"
}

variable "domain_zone" {
  type = string
  default = "tperd.splashtop.eu"
}

variable "cloudwatch_kms" {
  type = string
  default = "arn:aws:kms:ap-northeast-1:385284847228:key/mrk-21f69603552e41ac9defe7d976b433cf"
}