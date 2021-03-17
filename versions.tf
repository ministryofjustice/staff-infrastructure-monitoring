terraform {
  required_version = "> 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.32.0"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "1.9.0"
    }
  }
}