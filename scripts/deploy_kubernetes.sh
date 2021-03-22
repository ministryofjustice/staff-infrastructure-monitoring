#!/bin/bash

set -euox pipefail

export KUBECONFIG="./kubernetes/kubeconfig"

TEMP_ROLE=`aws sts assume-role --role-arn $TF_VAR_assume_role --role-session-name ci-authenticate-kubernetes-782`

access_key=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
secret_access_key=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
session_token=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')

cluster_role_arn=$(terraform output eks_cluster_worker_iam_role_arn)
prometheus_image_repo=$(terraform output -json prometheus_repository_v2 | jq  '.repository_url' | sed 's/"//g')
cluster_name=$(terraform output eks_cluster_id)

echo $(AWS_ACCESS_KEY_ID=$access_key AWS_SECRET_ACCESS_KEY=$secret_access_key AWS_SESSION_TOKEN=$session_token aws  sts get-caller-identity)

# SAVE KUBECONFIG FILE
AWS_ACCESS_KEY_ID=$access_key AWS_SECRET_ACCESS_KEY=$secret_access_key AWS_SESSION_TOKEN=$session_token aws eks --region eu-west-2 update-kubeconfig --name $cluster_name --role-arn $TF_VAR_assume_role

# UPDATE CONFIGMAP
helm upgrade --install mojo-$ENV-ima-configmap ./kubernetes/auth-configmap --set rolearn=$cluster_role_arn

# DEPLOY PROMETHEUS
helm upgrade --install mojo-$ENV-ima-prometheus ./kubernetes/imap-prometheus --set prometheus.image=$prometheus_image_repo
