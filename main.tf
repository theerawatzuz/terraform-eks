module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.0"

    name = "eks-demo-vpc"
    cidr = "10.0.0.0/16"

    azs = ["ap-southeast-1a", "ap-southeast-1b"]
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

    enable_nat_gateway = false
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20.0"

    cluster_name = "sre-demo"
    cluster_version = "1.29"

    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.public_subnets

    eks_managed_node_groups = {
        default = {
            instance_types = ["t3.medium"]
            min_size = 1
            max_size = 3
            desired_size = 1
        }
    }
}