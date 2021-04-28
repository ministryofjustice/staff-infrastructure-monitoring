#!/bin/bash

set -euo pipefail

terraform_outputs=$(terraform output -json)
env=$(echo $terraform_outputs | jq '.env.value' | sed 's/"//g')

aws ssm put-parameter --name "/terraform_staff_infrastructure_monitoring/$env/outputs" \
  --description "Terraform outputs that other pipelines or processes depend on" \
  --value "$terraform_outputs" \
  --type String \
  --overwrite \
  --tier "Advanced"

