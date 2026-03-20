# EFS FileSystem สำหรับ shared storage
resource "aws_efs_file_system" "shared_storage" {
  creation_token = "sre-demo-shared"
  
  performance_mode = "generalPurpose"
  throughput_mode  = "provisioned"
  provisioned_throughput_in_mibps = 100
  
  encrypted = true
  
  tags = {
    Name        = "sre-demo-shared-storage"
    Environment = "lab"
    Project     = "sre-demo"
  }
}

# EFS Mount Targets
resource "aws_efs_mount_target" "shared_storage" {
  count = length(module.vpc.public_subnets)
  
  file_system_id  = aws_efs_file_system.shared_storage.id
  subnet_id       = module.vpc.public_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

# Security Group สำหรับ EFS
resource "aws_security_group" "efs" {
  name_prefix = "sre-demo-efs-"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "sre-demo-efs-sg"
  }
}

# EFS StorageClass
resource "kubernetes_storage_class" "efs" {
  depends_on = [module.eks]
  
  metadata {
    name = "efs-sc"
  }
  
  storage_provisioner = "efs.csi.aws.com"
  
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.shared_storage.id
    directoryPerms   = "0755"
  }
}