variable "enable_guardduty" {
    description = "Set to true to enable GuardDuty and all selected features"
    type        = bool
    default     = false
}

variable "features" {
    description = "List of security guardrail features to enable"
    type        = object({
      s3_protection           = bool
      eks_runtime_monitoring  = bool
      eks_protection          = bool
      malware_protection      = bool
      rds_protection          = bool
      lambda_network_logs     = bool
      vpc_flow_logs           = bool
      dns_logs                = bool 
    })
    default = {
      s3_protection           = true
      eks_runtime_monitoring  = false
      eks_protection          = true
      malware_protection      = false
      rds_protection          = true
      lambda_network_logs     = true
      vpc_flow_logs           = true
      dns_logs                = true
    }
}

variable "enable_securityhub" {
    description = "Set to true to enable AWS Security Hub"
    type        = bool
    default     = false
}

variable "securityhub_standards" {  
    description = "List of Security Hub standards to enable"
    type        = list(object({
        name    = string
        version = string
    }))
    validation {
      condition = alltrue([
        for s in var.securityhub_standards : 
        contains(keys(local.securityhub_standard_arns), s.name) &&
        contains(keys(local.securityhub_standard_arns[s.name]), s.version)
      ])
      error_message = "Invalid security hub standard or version. Check available names & versions in locals."
    }
    default     = []
}

variable "enable_config" {
    description = "Set to true to enable AWS Config. Must only be enabled in a standalone or isolated account."
    type        = bool
    default     = false
}

variable "enable_cloudtrail" {
    description = "Set to true to enable AWS CloudTrail"
    type        = bool
    default     = false
}

variable "trail_name" {
    description = "Name of the CloudTrail trail to create"
    type        = string
    default     = "guardrails-cloudtrail"
}

variable "enable_cloudwatch_log_group" {
    description     = "Enable cloudwatch log group to cloudtrail"
    type            = bool
    default         = false
}

variable "cloudwatch_log_group_retention_in_days" {
    description = "Number of days to retain CloudWatch log group data"
    type        = number
    default     = 60
}

variable "cloudtrail_multi_region" {
    description = "Set to true to enable multi-region CloudTrail"
    type        = bool
    default     = false
}

variable "cloudtrail_log_file_validation" {
    description = "Set to true to enable log file validation for CloudTrail"
    type        = bool
    default     = false
}

variable "include_global_service_events" {
    description = "Set to true to include global service events in CloudTrail"
    type        = bool
    default     = true
}

variable "kms_key_id" {
    description = "KMS Key ID for encrypting CloudTrail logs."
    type        = string
    default     = null
}   

variable "s3_prefix" { 
    description = "S3 key prefix for CloudTrail log files"
    type        = string
    default     = null
}

variable "enable_organization_trail" {
    description = "Enable AWS Organization-wide CloudTrail.  Must be deployed in management account."
    type        = bool
    default     = false

    validation {
      condition = (
        var.enable_organization_trail == false || (var.enable_organization_trail == true)
      )
      error_message = "Organization-wide CloudTrail can only be enabled in the AWS Organization management account."
    }
}

variable "enable_access_analyzer" {
    description = "Set to true to enable AWS Access Analyzer"
    type        = bool
    default     = false
}

variable "enable_s3_public_block" {
    description = "Set to true to enable S3 Block Public Access"
    type        = bool
    default     = false
}

