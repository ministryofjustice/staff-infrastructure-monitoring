terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.75.0"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "1.24.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.3.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}
