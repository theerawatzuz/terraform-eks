module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.0"

    name = "eks-demo-vpc"
    cidr = "10.0.0.0/16"

    azs = ["ap-southeast-1a", "ap-southeast-1b"]
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

    enable_nat_gateway = false

    map_public_ip_on_launch = true

    public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
    }
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.0"

    cluster_name    = "sre-demo"
    cluster_version = "1.32"

    enable_cluster_creator_admin_permissions = true

    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.public_subnets

    cluster_endpoint_public_access = true

    enable_irsa = true

    cluster_addons = {
        coredns = {}
        kube-proxy = {}
        vpc-cni = {}
    }

    eks_managed_node_groups = {
        default_v2 = {
            instance_types = ["m7i-flex.large"]

            min_size     = 1
            max_size     = 3
            desired_size = 2

            capacity_type = "ON_DEMAND"

            labels = {
                role = "general"
            }

           tags = {
            "k8s.io/cluster-autoscaler/enabled" = "true"
            "k8s.io/cluster-autoscaler/sre-demo" = "owned"
            }
        }
    }

    tags = {
        Environment = "lab"
        Project     = "sre-demo"
        Terraform   = "true"
    }
}

module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.5"

  role_name                        = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = ["sre-demo"]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  depends_on = [module.eks]

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = "sre-demo"
  }

  set {
    name  = "awsRegion"
    value = "ap-southeast-1"
  }

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler_irsa.iam_role_arn
  }
}