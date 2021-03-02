#!/bin/bash

set -euo pipefail

git_repo_name=$(basename `git rev-parse --show-toplevel`)
terraform_outputs=$(terraform output -json)

echo $git_repo_name

aws ssm put-parameter --name "/terraform_$git_repo_name/$ENV/outputs" \
  --description "Terraform outputs that other pipelines or processes depend on" \
  --value "$terraform_outputs" \
  --type String \
  --overwrite