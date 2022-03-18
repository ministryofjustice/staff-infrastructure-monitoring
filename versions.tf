terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.75.0"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "1.17.0"
    }
  }
}
