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
    })
    default = {
      s3_protection           = false
      eks_runtime_monitoring  = false
      eks_protection          = false
      malware_protection      = false
      rds_protection          = false 
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

variable "enable_cloudtrail" {
    description = "Set to true to enable AWS CloudTrail"
    type        = bool
    default     = false
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

