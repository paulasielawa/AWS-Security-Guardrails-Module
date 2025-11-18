# Enable GuardDuty with S3 Protection
resource "aws_guardduty_detector" "detector" {
    count = var.enable_guardduty ? 1 : 0
    enable = true
}

resource "aws_guardduty_detector_feature" "s3_protection" {
  count = var.features.s3_protection ? 1 : 0
  
  detector_id = aws_guardduty_detector.detector[0].id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  count = var.features.eks_runtime_monitoring ? 1 : 0
  
  detector_id = aws_guardduty_detector.detector[0].id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_protection" {
  count = var.features.eks_protection ? 1 : 0
  
  detector_id = aws_guardduty_detector.detector[0].id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "malware_protection" {
  count = var.features.malware_protection ? 1 : 0
  
  detector_id = aws_guardduty_detector.detector[0].id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "rds_protection" {
  count = var.features.rds_protection ? 1 : 0
  
  detector_id = aws_guardduty_detector.detector[0].id
  name        = "RDS_LOGIN_EVENTS"
  status      = "ENABLED"
  
}

# Enable Security Hub
resource "aws_securityhub_account" "securityhub_acc" {
    count = var.enable_securityhub ? 1 : 0
}

resource "aws_securityhub_standards_subscription" "securityhub_standards" {
    count = var.enable_securityhub ? length(var.securityhub_standards) : 0

    standards_arn = local.securityhub_standard_arns[var.securityhub_standards[count.index].name][var.securityhub_standards[count.index].version]
    depends_on    = [aws_securityhub_account.securityhub_acc]
}