locals {
  features = {
    S3_DATA_EVENTS        = var.features.s3_protection
    EKS_RUNTIME_MONITORING = var.features.eks_runtime_monitoring
    EKS_AUDIT_LOGS        = var.features.eks_protection
    EBS_MALWARE_PROTECTION = var.features.malware_protection
    RDS_LOGIN_EVENTS      = var.features.rds_protection
    LAMBDA_NETWORK_LOGS   = var.features.lambda_network_logs
    VPC_FLOW_LOGS         = var.features.vpc_flow_logs
    DNS_LOGS              = var.features.dns_logs
  }
  
  securityhub_standard_arns = {
    "cis-aws-foundations-benchmark" = {
        "v3.0.0" = "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/3.0.0",
        "v1.4.0" = "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/1.4.0",
        # this v1.2.0 it is enabled by default in security hub
        "v1.2.0" = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
    }   
    # aws foundational security best practices it is enabled by default in security hub       
    "aws-foundational-security-best-practices" = {
        "v1.0.0" = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
    }      
    "pci-dss" = {
        "v3.2.1" = "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/3.2.1"
        "v4.0.1"   = "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/4.0.1"
    }
    "nist-800-171-rev-2" = {
        "v2.0.0" = "arn:aws:securityhub:${data.aws_region.current.name}::standards/nist-800-171/v/2.0.0"
    }
    "nist-800-53-rev-5" = {
        "v5.0.0" = "arn:aws:securityhub:${data.aws_region.current.name}::standards/nist-800-53/v/5.0.0"
    }
    "aws-resource-tagging-standard" = {
        "v1.0.0" = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-resource-tagging-standard/v/1.0.0"
    }
  }

  bucket_name = "${var.trail_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-logs"
  bucket_arn  = "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_name}"

  resource_path = var.s3_prefix == null || var.s3_prefix == "" ? "AWSLogs/${data.aws_caller_identity.current.account_id}/*" : "${trim(var.s3_prefix,"/")}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"

  organization_id = var.enable_organization_trail ? data.aws_organizations_organization.current[0].id : null
}
