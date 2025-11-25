# AWS-Security-Guardrails-Module
This Terraform module deploys a set of AWS security guardrails across an account or organization. It includes:

- **GuardDuty** detector and features
- **Security Hub** account with configurable standards
- **CloudTrail** setup with optional organization-wide trails and CloudWatch integration
- **AWS Config** for resource recording in standalone/isolated accounts
- **Access Analyzer** for account-level or organization-level 
- **S3 Public Access Block** for enforcing account-wide S3 public access restrictions

The module is designed to be reusable and configurable across multiple accounts and regions.

---

## Features

- **GuardDuty**: Core detection and optional features:
  - S3 protection
  - EKS runtime monitoring
  - EKS audit logs
  - Malware protection (EBS)
  - RDS login events
  - Lambda network activity logs 
  - VPC Flow Logs
  - DNS query logs

- **Security Hub**: Enable configurable standards with version selection:
  - CIS AWS Foundations Benchmark
  - AWS Foundational Security Best Practices
  - PCI DSS
  - NIST 800-171 Rev 2
  - NIST 800-53 Rev 5

- **CloudTrail**:
  - Optional trail creation
  - Multi-region support
  - CloudWatch Logs integration
  - Optional KMS encryption
  - Optional organization-wide trail (requires AWS Organizations)

- **AWS Config**: 
  - AWS Config must only be enabled in standalone or isolated accounts.
  - If you are using AWS Organizations, Control Tower, or Central Governance, then AWS Config is already managed at the organization level.
  - In those environments, enabling AWS Config inside this module will conflict with the org-level recorder.

- **Access Analyzer**:
  - Account-level analyzer
  - Organization-level analyzer (requires management account)

- **S3 Public Access Block**:
  - Account-level enforcement of S3 public access restrictions
  - Blocks public ACLs, public bucket policies, and ignores public ACLs

---

## Usage

```hcl
module "guardrails" {
  source = "git::https://github.com/your-repo/aws-guardrails.git"

  enable_guardduty = true
  features = {
    s3_protection           = true
    eks_runtime_monitoring  = false
    eks_protection          = true
    malware_protection      = true
    rds_protection          = true
    lambda_network_logs     = true
    vpc_flow_logs           = true
    dns_logs                = true
  }

  enable_securityhub = true
  securityhub_standards = [
    { name = "cis-aws-foundations-benchmark", version = "v5.0.0" },
    { name = "aws-foundational-security-best-practices", version = "v1.0.0" }
  ]

  enable_cloudtrail             = true
  trail_name                    = "audit-trail"
  cloudtrail_multi_region       = true
  enable_organization_trail     = false
  kms_key_id                    = null
  s3_prefix                     = "logs"
  enable_cloudwatch_log_group   = true
  cloudwatch_log_group_retention_in_days = 30

  enable_config                 = true

  enable_access_analyzer_account       = true
  enable_access_analyzer_organization = false
  is_management_account                = false

  enable_s3_public_block = true

  tags = {
    Environment = "prod"
    Team        = "security"
  }
}
```
## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enable_guardduty` | `bool` | `false` | Set to true to enable GuardDuty and all selected features |
| `features` | `object` | `{ s3_protection = true, eks_runtime_monitoring = false, eks_protection = true, malware_protection = false, rds_protection = true, lambda_network_logs = true, vpc_flow_logs = true, dns_logs = true }` | GuardDuty features to enable: `s3_protection`, `eks_runtime_monitoring`, `eks_protection`, `malware_protection`, `rds_protection`, `lambda_network_logs`, `vpc_flow_logs`, `dns_logs` |
| `enable_securityhub` | `bool` | `false` | Enable Security Hub account |
| `securityhub_standards` | `list(object)` | `[]` | Security Hub standards to enable. Each object: `{ name = string, version = string }` |
| `enable_config` | `bool` | `false` | Enable AWS Config. Only for standalone/isolated accounts |
| `enable_cloudtrail` | `bool` | `false` | Enable CloudTrail trail |
| `trail_name` | `string` | `"guardrails-cloudtrail"` | Name of the CloudTrail trail |
| `cloudtrail_multi_region` | `bool` | `false` | Enable multi-region CloudTrail |
| `cloudtrail_log_file_validation` | `bool` | `false` | Enable log file validation for CloudTrail |
| `include_global_service_events` | `bool` | `true` | Include global service events in CloudTrail |
| `kms_key_id` | `string` | `null` | KMS key ID for CloudTrail encryption (optional) |
| `s3_prefix` | `string` | `null` | S3 key prefix for CloudTrail logs |
| `enable_cloudwatch_log_group` | `bool` | `false` | Enable CloudWatch log group for CloudTrail |
| `cloudwatch_log_group_retention_in_days` | `number` | `60` | Retention period for CloudWatch log group |
| `is_management_account` | `bool` | `false` | Set to true when running in AWS Organization management account |
| `enable_organization_trail` | `bool` | `false` | Enable organization-wide CloudTrail. Requires management account |
| `enable_access_analyzer_account` | `bool` | `false` | Enable AWS Access Analyzer in the account |
| `enable_access_analyzer_organization` | `bool` | `false` | Enable AWS Access Analyzer in the organization. Requires management account |
| `enable_s3_public_block` | `bool` | `false` | Enable S3 Block Public Access at the account level |
| `tags` | `map(string)` | `{}` | Tags applied to all resources |



## Notes

Organization-wide CloudTrail: Requires AWS Organizations enabled. If used in a normal account, set enable_organization_trail = false.

Validation: Security Hub standards and versions are validated against a predefined list in the module locals.

Modularity: GuardDuty, Security Hub, and CloudTrail can be selectively enabled without deploying the others.

AWS Config: Only enable in isolated/standalone accounts; enabling in org-managed environments may conflict with centralized Config.

Access Analyzer: Organization-level analyzers require management account deployment.

S3 Public Access Block: Account-level enforcement blocks public access for all buckets; cannot enforce across multiple accounts from a single module.
