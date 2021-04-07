#!/bin/bash

set -euo pipefail

export KUBECONFIG="./kubernetes/kubeconfig"
outputs=$(terraform output -json)
env=$(echo $outputs | jq '.env.value' | sed 's/"//g')
assume_role=$(echo $outputs | jq '.assume_role.value' | sed 's/"//g')
echo $assume_role
TEMP_ROLE=`aws sts assume-role --role-arn $assume_role --role-session-name ci-authenticate-kubernetes-782`

access_key=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
secret_access_key=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
session_token=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')

cluster_role_arn=$(echo $outputs | jq '.eks_cluster_worker_iam_role_arn.value' | sed 's/"//g')
prometheus_image_repo=$(echo $outputs | jq '.prometheus_repository_v2.value.repository_url' | sed 's/"//g')
cluster_name=$(echo $outputs | jq  '.eks_cluster_id.value' | sed 's/"//g')
prometheus_thanos_storage_bucket_name=$(echo $outputs | jq '.prometheus_thanos_storage_bucket_name.value' | sed 's/"//g')
prometheus_thanos_storage_kms_key_id=$(echo $outputs | jq '.prometheus_thanos_storage_kms_key_id.value' | sed 's/"//g')

# SAVE KUBECONFIG FILE
AWS_ACCESS_KEY_ID=$access_key AWS_SECRET_ACCESS_KEY=$secret_access_key AWS_SESSION_TOKEN=$session_token aws eks\
    --region eu-west-2 update-kubeconfig --name $cluster_name --role-arn $assume_role

# UPDATE CONFIGMAP
echo "Deploying auth configmap"
helm upgrade --install --atomic mojo-$env-ima-configmap ./kubernetes/auth-configmap --set rolearn=$cluster_role_arn

#TEMP - uninstalling old chart in order to rename
helm uninstall mojo-$env-ima-prometheus-thanos

# DEPLOY PROMETHEUS
echo "Deploying Prometheus"
helm upgrade --install --atomic mojo-$env-ima ./kubernetes/prometheus-thanos --set \
prometheus.image=$prometheus_image_repo,\
alertmanager.image=prom/alertmanager,\
prometheusThanosStorageBucket.bucketName=$prometheus_thanos_storage_bucket_name,\
prometheusThanosStorageBucket.kmsKeyId=$prometheus_thanos_storage_kms_key_id,\
thanos.image=$TF_VAR_thanos_image_repository_url

# Display all Pods
echo "List of Pods:"
kubectl get pods
