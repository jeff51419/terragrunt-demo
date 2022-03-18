### provider ###

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
####################
variable "name" {
  type    = string
  default = "stp-vpc-project"
}

variable "vpc_az_start" {
  type    = number
  default = 0
}

variable "vpc_az_end" {
  type    = number
  default = 3
}

variable "vpc_cidr" {
  type    = string
  default = "10.117.0.0/16"
}
variable "vpc_pri_subnets" {
  type = list(string)
  default = [
    "10.117.0.0/24"
  ]
}
variable "vpc_pub_subnets" {
  type = list(string)
  default = [
    "10.117.1.0/24"
  ]
}

# NAT Gateway
variable "enable_nat_gateway" {
  type = bool
  default = true
}

variable "single_nat_gateway" {
  type = bool
  default = false
}

variable "one_nat_gateway_per_az" {
  type = bool
  default = false
}

variable "vpc_database_subnets" {
  type = list(string)
  default = [
    "10.117.100.0/24"
  ]
}

variable "create_database_subnet_group" {
  type    = bool
  default = false
}

variable "vpc_reuse_nat_ips" {
  type    = bool
  default = false
}

variable "vpc_nat_eip_ids" {
  type = list(string)
  default = []
    // "eipalloc-xxxxxxxxxxxxxxxxx",
    // "eipalloc-xxxxxxxxxxxxxxxxx"
}

variable "vpc_nat_ips_count" {
  type    = number
  default = 0
}

### SG whitelist ###
variable "sg_whitelist_ips" {
  type = list(string)
  default = [
  "1.1.1.1/32",           # NYY office 1
  "2.2.2.2/32",           # NYY office 2
  "111.111.111.111/32",   # LDN office
  "222.222.222.222/32",   # TPE office 1
  "61.61.61.61/32"        # TPE office 2
  ]
}