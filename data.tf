#Fetch information about the current AWS caller identity and region
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_organizations_organization" "current" {
    count = var.enable_organization_trail ? 1 : 0
}
