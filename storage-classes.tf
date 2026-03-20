# Default StorageClass สำหรับ EBS volumes
resource "kubernetes_storage_class" "gp3" {
  depends_on = [module.eks]
  
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  
  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
  }
}

# StorageClass สำหรับ Prometheus (optimized for time-series data)
resource "kubernetes_storage_class" "prometheus" {
  depends_on = [module.eks]
  
  metadata {
    name = "prometheus-storage"
  }
  
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  
  parameters = {
    type       = "gp3"
    iops       = "3000"
    throughput = "250"
    encrypted  = "true"
    fsType     = "ext4"
  }
}

# StorageClass สำหรับ high-performance workloads
resource "kubernetes_storage_class" "io2" {
  depends_on = [module.eks]
  
  metadata {
    name = "io2-high-iops"
  }
  
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  
  parameters = {
    type = "io2"
    iops = "1000"
    encrypted = "true"
    fsType = "ext4"
  }
}

# StorageClass สำหรับ databases
resource "kubernetes_storage_class" "gp3_database" {
  depends_on = [module.eks]
  
  metadata {
    name = "gp3-database"
  }
  
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  
  parameters = {
    type      = "gp3"
    iops      = "3000"
    throughput = "125"
    encrypted = "true"
    fsType    = "ext4"
  }
}