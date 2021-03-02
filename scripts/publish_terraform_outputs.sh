#!/bin/bash

set -euo pipefail

git_dir=$(git rev-parse --show-toplevel)
git_repo_name=$(basename $git_dir)
terraform_outputs=$(terraform output -json)

aws ssm put-parameter --name "/terraform_$git_repo_name/$ENV/outputs" \
  --description "Terraform outputs that other pipelines or processes depend on" \
  --value "$terraform_outputs" \
  --type String \
  --overwrite