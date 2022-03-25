data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_caller_identity" "current" {}

data "aws_security_groups" "stp-vpc-sg" {
  filter {
    name   = "vpc-id"
    values = [
      module.vpc.vpc_id
    ]
  }

  filter {
    name   = "group-name"
    values = [
      "*default*"
    ]
  }

  depends_on = [module.vpc]
}