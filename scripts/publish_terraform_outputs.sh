#!/bin/bash

set -euo pipefail

terraform_outputs=$(terraform output -json)

aws ssm put-parameter --name "/terraform_staff_infrastructure_monitoring/$ENV/outputs" \
  --description "Terraform outputs that other pipelines or processes depend on" \
  --value "$terraform_outputs" \
  --type String \
  --overwrite
