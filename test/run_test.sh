#!/bin/sh

domain="`grep -m 1 '^vpn_hosted_zone_domain' ../terraform.tfvars`"
prefix="`grep -m 1 '^domain_prefix' ../terraform.tfvars`"
username="`grep -m 1 '^grafana_admin_username' ../terraform.tfvars`"
password="`grep -m 1 '^grafana_admin_password' ../terraform.tfvars`"

echo "Running rspec"

eval "TF_VAR_${domain//[[:blank:]]/} \
      TF_VAR_${prefix//[[:blank:]]/} \
      TF_VAR_${username//[[:blank:]]/}\
      TF_VAR_${password//[[:blank:]]/} \
      bundle exec rspec --format documentation"
