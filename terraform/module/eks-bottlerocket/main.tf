locals {
  # substr(string, offset, length)
  cluster_name_project = lower(var.project)
  cluster_name_region  = join("", [substr(replace(var.region, "-", ""), 0, 3), regex("\\d$", var.region)])
  cluster_name_env     = substr(var.environment, 0, 4)
  cluster_name_account = var.account
  cluster_name_suffix  = "${local.cluster_name_env}-${local.cluster_name_region}-${random_string.suffix.result}"

  name            = "${local.cluster_name_project}-${local.cluster_name_suffix}"
  cluster_version = var.cluster_version
  region          = var.region

  tags = {
    Project     = var.project
    Environment = var.environment
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.10.0"

  create = var.create

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  # whitelist_ip
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # Self Managed Node Group(s)
  # SSM policy for bottlerocket control container access
  # https://github.com/bottlerocket-os/bottlerocket/blob/develop/QUICKSTART-EKS.md#enabling-ssm
  self_managed_node_group_defaults = {
    disk_size = 50
  }

  # Default node group - as provisioned by the module defaults
  self_managed_node_groups = {
    default_node_group = {}

    # Bottlerocket node group
    bottlerocket = {
      name          = "bottlerocket-self-mng"

      platform      = "bottlerocket"
      ami_id        = data.aws_ami.eks_default_bottlerocket.id
      min_size      = 1
      max_size      = 3
      desired_size  = 2
      instance_type = "m5.large"

      iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

      bootstrap_extra_args = <<-EOT
      # The admin host container provides SSH access and runs with "superpowers".
      # It is disabled by default, but can be disabled explicitly.
      [settings.host-containers.admin]
      enabled = false
      # The control host container provides out-of-band access via SSM.
      # It is enabled by default, and can be disabled if you do not expect to use SSM.
      # This could leave you with no way to access the API and change settings on an existing node!
      [settings.host-containers.control]
      enabled = true
      [settings.kubernetes.node-labels]
      ingress = "allowed"
      EOT

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = false
            volume_size           = 100
            volume_type           = "gp3"
            throughput            = 300
          }
        }
      }
    }

    // mixed = {
    //   name = "mixed"

    //   min_size     = 1
    //   max_size     = 5
    //   desired_size = 2

    //   bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

    //   use_mixed_instances_policy = true
    //   mixed_instances_policy = {
    //     instances_distribution = {
    //       on_demand_base_capacity                  = 0
    //       on_demand_percentage_above_base_capacity = 20
    //       spot_allocation_strategy                 = "capacity-optimized"
    //     }

    //     override = [
    //       {
    //         instance_type     = "m5.large"
    //         weighted_capacity = "1"
    //       },
    //       {
    //         instance_type     = "m6i.large"
    //         weighted_capacity = "2"
    //       },
    //     ]
    //   }
    // }

    # Complete
    // complete = {
    //   name            = "complete-self-mng"
    //   use_name_prefix = false

    //   subnet_ids = var.subnet_ids

    //   min_size     = 1
    //   max_size     = 7
    //   desired_size = 1

    //   ami_id               = data.aws_ami.eks_default.id
    //   bootstrap_extra_args = "--kubelet-extra-args '--max-pods=110'"

    //   pre_bootstrap_user_data = <<-EOT
    //   export CONTAINER_RUNTIME="containerd"
    //   export USE_MAX_PODS=false
    //   EOT

    //   post_bootstrap_user_data = <<-EOT
    //   echo "you are free little kubelet!"
    //   EOT

    //   disk_size     = 256
    //   instance_type = "m6i.large"

    //   launch_template_name            = "self-managed-ex"
    //   launch_template_use_name_prefix = true
    //   launch_template_description     = "Self managed node group example launch template"

    //   ebs_optimized          = true
    //   vpc_security_group_ids = [aws_security_group.additional.id]
    //   enable_monitoring      = true

    //   block_device_mappings = {
    //     xvda = {
    //       device_name = "/dev/xvda"
    //       ebs = {
    //         volume_size           = 75
    //         volume_type           = "gp3"
    //         iops                  = 3000
    //         throughput            = 150
    //         encrypted             = true
    //         kms_key_id            = aws_kms_key.ebs.arn
    //         delete_on_termination = true
    //       }
    //     }
    //   }

    //   metadata_options = {
    //     http_endpoint               = "enabled"
    //     http_tokens                 = "required"
    //     http_put_response_hop_limit = 2
    //     instance_metadata_tags      = "disabled"
    //   }

    //   create_iam_role          = true
    //   iam_role_name            = "self-managed-node-group-complete-example"
    //   iam_role_use_name_prefix = false
    //   iam_role_description     = "Self managed node group complete example role"
    //   iam_role_tags = {
    //     Purpose = "Protector of the kubelet"
    //   }
    //   iam_role_additional_policies = [
    //     "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    //   ]

    //   create_security_group          = true
    //   security_group_name            = "self-managed-node-group-complete-example"
    //   security_group_use_name_prefix = false
    //   security_group_description     = "Self managed node group complete example security group"
    //   security_group_rules = {
    //     phoneOut = {
    //       description = "Hello CloudFlare"
    //       protocol    = "udp"
    //       from_port   = 53
    //       to_port     = 53
    //       type        = "egress"
    //       cidr_blocks = ["1.1.1.1/32"]
    //     }
    //     phoneHome = {
    //       description                   = "Hello cluster"
    //       protocol                      = "udp"
    //       from_port                     = 53
    //       to_port                       = 53
    //       type                          = "egress"
    //       source_cluster_security_group = true # bit of reflection lookup
    //     }
    //   }
    //   security_group_tags = {
    //     Purpose = "Protector of the kubelet"
    //   }

    //   timeouts = {
    //     create = "80m"
    //     update = "80m"
    //     delete = "80m"
    //   }

    //   tags = {
    //     ExtraTag = "Self managed node group complete example"
    //   }
    // }

    tags = local.tags
  }
}



################################################################################
# aws-auth configmap
# Only EKS managed node groups automatically add roles to aws-auth configmap
# so we need to ensure fargate profiles and self-managed node roles are added
################################################################################

// data "aws_eks_cluster_auth" "this" {
//   name = module.eks.cluster_id
// }

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
}

resource "null_resource" "apply" {
  triggers = {
    kubeconfig = base64encode(local.kubeconfig)
    cmd_patch  = <<-EOT
      kubectl create configmap aws-auth -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl patch configmap/aws-auth --patch "${module.eks.aws_auth_configmap_yaml}" -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
    EOT
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
    command = self.triggers.cmd_patch
  }
}