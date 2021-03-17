
## Set up connection to the cluster

1. set env variable for locaiton of kube config file
```
export KUBECONFIG=./kubernetes/kubeconfig
```
2. Create kubeconfig - this saves connection settings to allow you to communicate with the cluster via `kubectl`. Replace `<cluster_name>` with the name of your cluster, which you can find in the terraform  outputs.
```
aws-vault exec moj-dev -- aws eks --region eu-west-2 update-kubeconfig --name <cluster_name> --kubeconfig ./kubernetes/kubeconfig --role-arn arn:aws:iam::068084030754:role/pttp-global-monitoring-shared-services-admin
```
3. Check can connect with kubectl
```
aws-vault exec moj-shared-services -- kubectl get svc
```
## Create a config map for authentication
 This is needed to give the worker instances the correct permissions to connect themselves to nodes in the cluster.
1. Download an auth config map
```
curl -o ./kubernetes/aws-auth-cm.yaml https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/aws-auth-cm.yaml
```
2. Go into file and replace `<ARN of instance role (not instance profile)>` with "eks_cluster_role_arn" from terraform outputs

3. Apply config map
```
aws-vault exec moj-shared-services -- kubectl apply -f ./kubernetes/aws-auth-cm.yaml
```
4. Check the config map has applied
```
aws-vault exec moj-shared-services -- kubectl describe configmap -n kube-system aws-auth
```

## Deploy prometheus with helm for the first time

1. Move into kubernetes folder
```
cd ./kubernetes
```

2. Download prometheus community repository
```
helm pull prometheus-community/prometheus
```
3. unzip it
```
tar -zvxf prometheus-13.6.0.tgz
```
4. Install prometheus onto your cluster. Replace name with what you want to call it
```
aws-vault exec moj-shared-services -- helm install ima-emma-prom  ./kubernetes/prometheus
```
5. Check the pods are running
``` 
aws-vault exec moj-shared-services -- kubectl get pods 
```

## To make changes to prometheus

```
aws-vault exec moj-shared-services -- helm upgrade  ima-emma-prom  ./kubernetes/prometheus 
```

## Port forward to localhost

```
aws-vault exec moj-shared-services -- kubectl port-forward pods/<pod_name> 9090:9090
```

## Get Logs for pod
```
aws-vault exec moj-shared-services -- kubectl logs <pod_name>  -c prometheus-server
```