# 1. Record architecture decisions

Date: 2021-22-03

## Status

🤔 Proposed

## Context

The infrastructure monitoring and alerting platform consists of a number of services deployed as docker containers. So far these containers have been running on ECS via Fargate, chosen because of the relative ease with which it allows us to get instances provisioned. 

As the solution has grown, and the interactions between new services have become more complex, we have found that we are running up against Fargate's limitations and require finer grained control over our deployments. 

Kubernetes is the industry standard platform for orchestrating and running container based deployments of servies, and provides considerably more flexibility in comparison to ECS and Fargate.

 
## Decision

Starting with Prometheus and Thanos, we are migrating our services over to AWS's managed kubernetes offering - EKS.

## Consequences

While it has the potential to be more complicated due to it's increased flexibility, we believe that in the long run Kubernetes will actually simplify the operation, maintainence, and improvement of the IMA platform. It offers a number of advantages over fargate:

- Better networking support out of the box enabling:
  - high availibility support
  - reduced need for networking infrastructure external to the cluster
- Decoupling of services from infrastructure leading to:
  - faster development cycle
  - Simpler and clearer configuration
  - Less reliance on specific infrastructure (could conceivably run on any kubernetes cluster, regardless of the provider)
  - Reduced overall costs as the team can share the same development kubernetes cluster 
- More aligned with common DevOps approaches in wider industry
