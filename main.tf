########################################
# GuardDuty Setup
########################################
resource "aws_guardduty_detector" "detector" {
    count = var.enable_guardduty ? 1 : 0
    enable = true
}

resource "aws_guardduty_detector_feature" "features" {
  for_each = var.enable_guardduty ? local.features : {}
  
  detector_id = aws_guardduty_detector.detector[0].id
  name = each.key
  status = each.value ? "ENABLED" : "DISABLED"
}

########################################
# Security Hub Setup
########################################
resource "aws_securityhub_account" "securityhub_acc" {
    count = var.enable_securityhub ? 1 : 0
}

resource "aws_securityhub_standards_subscription" "securityhub_standards" {
    count = var.enable_securityhub ? length(var.securityhub_standards) : 0

    standards_arn = local.securityhub_standard_arns[var.securityhub_standards[count.index].name][var.securityhub_standards[count.index].version]
    depends_on    = [aws_securityhub_account.securityhub_acc]
}
resource "aws_iam_role" "config" {
  name               = "default-awsconfig"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "config_role_attachment" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_s3_bucket" "config_bucket" {
  count  = var.enable_config ? 1 : 0

  bucket = "awsconfig-default-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  count  = var.enable_config ? 1 : 0

  bucket = aws_s3_bucket.config_bucket[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSConfigBucketPermissionsCheck"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.config_bucket[0].arn
      },
      {
        Sid       = "AWSConfigBucketDelivery"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.config_bucket[0].arn}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
  
}

resource "aws_config_configuration_recorder" "config_recorder" {
  count    = var.enable_config ? 1 : 0

  name     = "default"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "config_delivery_channel" {
  count          = var.enable_config ? 1 : 0

  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_bucket[0].bucket

  depends_on = [ aws_config_configuration_recorder.config_recorder ]
}

resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  count      = var.enable_config ? 1 : 0

  name       = aws_config_configuration_recorder.config_recorder[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

########################################
# Cloudtrail Setup
########################################
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.kms_key_id!= null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  # CloudTrail needs ACL check
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }
     
  # CloudTrail needs write permissions
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${local.bucket_arn}/${local.resource_path}"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    dynamic "condition" {
        for_each = var.enable_organization_trail ? [1] : []
        content {
          test     = "StringEquals"
          variable = "aws:PrincipalOrgID"
          values   = [local.organization_id]
        }
      
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

resource "aws_cloudwatch_log_group" "trail_log_group" {
    count = var.enable_cloudwatch_log_group && var.enable_cloudtrail ? 1 : 0

    name              = "/aws/cloudtrail/${var.trail_name}"
    retention_in_days = var.cloudwatch_log_group_retention_in_days
}

resource "aws_iam_role" "cloudtrail_cw_role" {
  count = var.enable_cloudwatch_log_group && var.enable_cloudtrail ? 1 : 0

  name = "${var.trail_name}-cloudtrail-cw-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cw_policy" {
  count = var.enable_cloudwatch_log_group && var.enable_cloudtrail ? 1 : 0

  name = "${var.trail_name}-cloudtrail-cw-policy"
  role = aws_iam_role.cloudtrail_cw_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream"
        ]
        Resource = "${aws_cloudwatch_log_group.trail_log_group[0].arn}:*"
      }
    ]
  })
  
}

resource "aws_cloudtrail" "cloudtrail" {
    count = var.enable_cloudtrail ? 1 : 0

    name                          = var.trail_name
    s3_bucket_name                = local.bucket_name
    include_global_service_events = var.include_global_service_events
    is_multi_region_trail         = var.cloudtrail_multi_region
    enable_log_file_validation    = var.cloudtrail_log_file_validation
    kms_key_id                    = var.kms_key_id
    s3_key_prefix                 = var.s3_prefix
    is_organization_trail         = var.enable_organization_trail

    cloud_watch_logs_role_arn     = var.enable_cloudwatch_log_group ? aws_iam_role.cloudtrail_cw_role[0].arn : null
    cloud_watch_logs_group_arn    = var.enable_cloudwatch_log_group ? aws_cloudwatch_log_group.trail_log_group[0].arn : null
    depends_on                    = [aws_s3_bucket_policy.cloudtrail_policy]
}

########################################
# Access Analyzer Setup
########################################
resource "aws_accessanalyzer_analyzer" "access_analyzer_account" {
    count = var.enable_access_analyzer_account ? 1 : 0

    analyzer_name = "account-analyzer"
    type          = "ACCOUNT"
}

resource "aws_accessanalyzer_analyzer" "access_analyzer_organization" {
    count = var.enable_access_analyzer_organization ? 1 : 0

    analyzer_name = "organization-analyzer"
    type          = "ORGANIZATION"
}
