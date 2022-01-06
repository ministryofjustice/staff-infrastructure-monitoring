module "label" {
  version = "0.24.0"
  source  = "cloudposse/label/null"

  delimiter = "-"
  name      = "IMA"
  namespace = var.label_namespace
  stage     = terraform.workspace

  tags = {
    "business-unit"    = "HQ"
    "environment-name" = "global"
    "owner"            = var.owner-email
    "is-production"    = var.is-production
    "application"      = "infrastructure-monitoring"
    "source-code"      = "https://github.com/ministryofjustice/staff-infrastructure-monitoring"
    "status"           = var.label_status
    "notes"            = var.label_notes
  }
}