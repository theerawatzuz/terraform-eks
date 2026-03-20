# IAM Role สำหรับ CloudWatch integration
module "cloudwatch_observability_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.5"

  role_name = "cloudwatch-observability"
  
  role_policy_arns = {
    CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    AmazonPrometheusRemoteWriteAccess = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
  }

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "monitoring:prometheus-server",
        "monitoring:cloudwatch-agent",
        "amazon-cloudwatch:cloudwatch-agent"
      ]
    }
  }
}

# Amazon Managed Prometheus Workspace
resource "aws_prometheus_workspace" "main" {
  alias = "sre-demo-prometheus"
  
  tags = {
    Environment = "lab"
    Project     = "sre-demo"
  }
}

# CloudWatch Log Groups สำหรับ container insights
resource "aws_cloudwatch_log_group" "container_insights" {
  name              = "/aws/containerinsights/sre-demo/application"
  retention_in_days = 7
  
  tags = {
    Environment = "lab"
    Project     = "sre-demo"
  }
}

resource "aws_cloudwatch_log_group" "container_insights_dataplane" {
  name              = "/aws/containerinsights/sre-demo/dataplane"
  retention_in_days = 7
  
  tags = {
    Environment = "lab"
    Project     = "sre-demo"
  }
}

resource "aws_cloudwatch_log_group" "container_insights_host" {
  name              = "/aws/containerinsights/sre-demo/host"
  retention_in_days = 7
  
  tags = {
    Environment = "lab"
    Project     = "sre-demo"
  }
}

resource "aws_cloudwatch_log_group" "container_insights_performance" {
  name              = "/aws/containerinsights/sre-demo/performance"
  retention_in_days = 7
  
  tags = {
    Environment = "lab"
    Project     = "sre-demo"
  }
}