
provider "aws" {
  region  = var.aws_region
  profile = var.environment

}

module "label" {
  version = "0.25.0"
  source  = "cloudposse/label/null"

  delimiter = "-"
  name      = "IMA"
  namespace = "staff-infra"
  stage     = var.environment

  tags = {
    "business-unit"    = "MoJO"
    "environment-name" = "global"
    "owner"            = var.owner-email
    "application"      = "Infrastructure Monitoring and Alerting"
    "source-code"      = "https://github.com/ministryofjustice/staff-infrastructure-monitoring"
  }
}
