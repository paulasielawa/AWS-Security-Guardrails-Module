# AWS-Security-Guardrails-Module
This Terraform module deploys a set of AWS security guardrails across an account or organization. It includes:

- **GuardDuty** detector and features
- **Security Hub** account with configurable standards
- **CloudTrail** setup with optional organization-wide trails and CloudWatch integration
- **S3 bucket** creation for CloudTrail logs with optional encryption

The module is designed to be reusable and configurable across multiple accounts and regions.

In progress: S3 Public Access Block and IAM Access Analyzer

---

## Features

- **GuardDuty**: Core detection and optional features:
  - S3 protection
  - EKS runtime monitoring
  - EKS audit logs
  - Malware protection (EBS)
  - RDS login events

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
  - Optional organization-wide trail

---

## Usage

```hcl
module "guardrails" {
  source = "git::https://github.com/your-repo/aws-guardrails.git"

  enable_guardduty = true
  features = {
    s3_protection          = true
    eks_runtime_monitoring = false
    eks_protection         = false
    malware_protection     = true
    rds_protection         = true
  }

  enable_securityhub = true
  securityhub_standards = [
    {
      name    = "cis-aws-foundations-benchmark"
      version = "v5.0.0"
    },
    {
      name    = "aws-foundational-security-best-practices"
      version = "v1.0.0"
    }
  ]

  enable_cloudtrail             = true
  trail_name                    = "audit-trail"
  cloudtrail_multi_region       = true
  enable_organization_trail     = false
  kms_key_id                    = null
  s3_prefix                     = "logs"
  enable_cloudwatch_log_group   = true
  cloudwatch_log_group_retention_in_days = 30

  tags = {
    Environment = "prod"
    Team        = "security"
  }

  subscriptions = {
    security = [
      {
        protocol = "email"
        endpoint = "security-team@example.com"
      }
    ]
    cost = []
    infra = []
  }
}
```
## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enable_guardduty` | `bool` | `true` | Enable GuardDuty detector |
| `features` | `object` | `{}` | GuardDuty features to enable: `s3_protection`, `eks_runtime_monitoring`, `eks_protection`, `malware_protection`, `rds_protection` |
| `enable_securityhub` | `bool` | `true` | Enable Security Hub account |
| `securityhub_standards` | `list(object)` | `[]` | Security Hub standards to enable. Each object: `{ name = string, version = string }` |
| `enable_cloudtrail` | `bool` | `true` | Enable CloudTrail trail |
| `trail_name` | `string` | `"cloudtrail"` | Name of the CloudTrail trail |
| `cloudtrail_multi_region` | `bool` | `false` | Enable multi-region CloudTrail |
| `enable_organization_trail` | `bool` | `false` | Enable organization-wide CloudTrail (requires AWS Organizations) |
| `kms_key_id` | `string` | `null` | KMS key ID for CloudTrail encryption (optional) |
| `s3_prefix` | `string` | `""` | S3 key prefix for CloudTrail logs |
| `enable_cloudwatch_log_group` | `bool` | `true` | Enable CloudWatch log group for CloudTrail |
| `cloudwatch_log_group_retention_in_days` | `number` | `1` | Retention period for CloudWatch log group |
| `tags` | `map(string)` | `{}` | Tags applied to all resources |
| `subscriptions` | `map(list(object))` | `{ security=[], cost=[], infra=[] }` | SNS endpoints for notifications. Each object: `{ protocol = string, endpoint = string }` |
| `function_name` | `string` | `"ai_notifier"` | Name of Lambda function (if using notifications module) |
| `timeout_in_seconds` | `number` | `30` | Lambda timeout in seconds |
| `memory_size_in_mb` | `number` | `128` | Lambda memory allocation |


## Notes

Organization-wide CloudTrail: Requires AWS Organizations enabled. If used in a normal account, set enable_organization_trail = false.

Validation: Security Hub standards and versions are validated against a predefined list in the module locals.

Modularity: GuardDuty, Security Hub, and CloudTrail can be selectively enabled without deploying the others.