locals {
  securityhub_standard_arns = {
    "cis_aws_foundations_benchmark" = {
        "v5.0.0" = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/5.0.0",
        "v3.0.0" = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/3.0.0",
        "v1.4.0" = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.4.0",
        "v1.2.0" = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
    }          
    "aws-foundational-security-best-practices" = {
        "v1.0.0" = "arn:aws:securityhub:::standards/aws-foundational-security-best-practices/v/1.0.0"
    }      
    "pci-dss" = {
        "v3.2.1" = "arn:aws:securityhub:${data.aws_region.current.region}::standards/pci-dss/v/3.2.1"
        "v4.0"   = "arn:aws:securityhub:${data.aws_region.current.region}::standards/pci-dss/v/4.0.0"
    }
    "nist-800-171-rev-2" = {
        "v2.0.0" = "arn:aws:securityhub:::standards/nist-800-171/v/2.0.0"
    }
    "nist-800-53-rev-5" = {
        "v5.0.0" = "arn:aws:securityhub:::standards/nist-800-53/v/5.0.0"
    }
  }
}
