#!/bin/bash

set -euo pipefail

get_outputs() {
  printf "\nGenerating tfvars file for workspace name: $ENV\n\n"

  tfvars=`aws ssm get-parameter --with-decryption --name /staff-infrastructure-monitoring/terraform.tfvars | jq -r .Parameter.Value`
}

get_outputs

cat <<EOF > terraform.tfvars
${tfvars}
EOF

echo "Take a look at your terraform.tfvars file and replace <YOUR-WORKSPACE-NAME> placeholder with... Well I'm sure you can guess!"
read -n 1 -r -s -p $'Press enter to continue...\n'
