module "eks" {
  source                           = "terraform-aws-modules/eks/aws"
  version                          = "19.0.4"
  cluster_name                     = local.cluster_name
  cluster_version                  = "1.27"
  vpc_id                           = module.vpc.vpc_id
  subnet_ids                       = slice(module.vpc.private_subnets, 0, 3)
  control_plane_subnet_ids         = slice(module.vpc.private_subnets, 3, 3)
  cluster_endpoint_public_access   = true
  attach_cluster_encryption_policy = false
  cluster_encryption_config        = {}
  create_cloudwatch_log_group      = false
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }
  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 2
    }
  }
}