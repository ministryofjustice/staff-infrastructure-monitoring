terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "3.75.0"
      configuration_aliases = [aws.env]
    }

    grafana = {
      source  = "grafana/grafana"
      version = "1.17.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.2"
    }
  }
}
