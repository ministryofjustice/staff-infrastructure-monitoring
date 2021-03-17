#!/bin/bash
export KUBECONFIG="./kubernetes/kubeconfig"

cluster_role_arn=$(GET THIS FROM TERRAFROM OUTPUTS) # THE ROLE ARN CURRENTLY BEING OUTPUT BY THE TERRAFORM ISNT THE CORRECT ONE
prometheus_image_repo=$(GET THIS FROM TF OUTPUTS - prometheus_repository_v2.repository_url)

# SAVE KUBECONFIG FILE

aws eks --region eu-west-2 update-kubeconfig --name mojo-$ENV-ima-cluster #MAYBE GET THE CLUTER NAME FROM TERRAFORM OUTPUTS AS WELL

# UPDATE CONFIGMAP
helm upgrade --install mojo-$ENV-ima-configmap ./kubernetes/auth-configmap --set rolearn=$cluster_role_arn

# DEPLOY PROMETHEUS
helm upgrade --install mojo-$ENV-ima-prometheus ./kubernetes/prometheus --set server.image.repository=$prometheus_image_repo