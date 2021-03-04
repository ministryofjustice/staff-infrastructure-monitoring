#!/bin/bash


# Use this script to extract the value of Terraform outputs from Parameter Store.
# 
# Usage: ./extract_params.sh <output_id> <value_id>
#
# eg: ./extract_params.sh snmp_exporter_repository repository_url
#

param_value=$(aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq '.Parameter.Value' | jq -r | jq '.'$1'.value.'$2)

echo $param_value
