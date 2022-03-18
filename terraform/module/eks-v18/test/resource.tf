################################################################################
# Supporting resources
################################################################################
resource "random_string" "suffix" {
  length  = 8
  upper   = false # no upper for RDS related resources naming rule
  special = false
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_security_group" "additional" {
  #checkov:skip=CKV2_AWS_5:the resource will be used
  #ts:skip=AC_AWS_0320 skip
  name_prefix = "eks-${local.cluster_name_project}-additional"
  vpc_id      = var.vpc_id
  description = "Allow inbound traffic to eks from VPC CIDR"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
    description = "allow port 22"
  }

  tags = local.tags
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "aws_key_pair" "this" {
  key_name   = local.name
  public_key = tls_private_key.this.public_key_openssh
}
#tfsec:ignore:aws-kms-auto-rotate-keys:skip key rotate
resource "aws_kms_key" "ebs" {
  #checkov:skip=CKV_AWS_7:sikp
  #ts:skip=AC_AWS_0160 skip key rotate
  description             = "Customer managed key to encrypt self managed node group volumes"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.ebs.json
}