# Alerts for the IMA Platform

Below are the alerts currently set for the IMA Platform. They have been
sectioned by the potential problem a user could have.

Those that are monitored by the IMA Platform are provisioned through the
[Configuration GitHub repository](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config)
within the [Monitoring Platform integrations directory](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config/tree/main/integrations/monitoring_platform).

## Potential user issues

### IMA Platform i.e. Grafana is unreachable

| Possible cause                  | Monitored by    | Alert                                             | Next step |
|---------------------------------|-----------------|---------------------------------------------------|-----------|
| Grafana ECS task fails to start | IMA Platform    | Number of running tasks is below 1                | Check the logs for the latest stopped task and decide whether to rollback (by reverting the latest changes) or roll forward (fix the issue). |
| Grafana has no healthy hosts    | AWS CloudWatch  | Number of healthy Grafana hosts < 1 for 2 minutes | Check the logs for the latest stopped task and decide whether to rollback (by reverting the latest changes) or roll forward (fix the issue). |

### IMA Platform is slow

> **Warning:** Increasing CPU or memory values for Fargate tasks are a manual task at the moment. We're looking to enable auto-scaling.

| Possible cause                                       | Monitored by | Alert                                 | Next step |
|------------------------------------------------------|--------------|---------------------------------------|-----------|
| Grafana ECS service CPU utilisation is high          | IMA Platform | CPU utilisation is higher than 50%    | Increase the [Grafana Fargate CPU value in the task definition](https://github.com/ministryofjustice/staff-infrastructure-monitoring/blob/05145d0b1208226b1317026197e814bf8068ab24/modules/grafana/service.tf#L7). |
| Grafana ECS service memory utilisation is high       | IMA Platform | Memory utilisation is higher than 50% | Increase the [Grafana Fargate Memory value in the task definition](https://github.com/ministryofjustice/staff-infrastructure-monitoring/blob/05145d0b1208226b1317026197e814bf8068ab24/modules/grafana/service.tf#L8). |
| Grafana database is running out of available storage | IMA Platform | Available storage space is below 5 GB | [Increase the storage capacity for the RDS instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html#USER_PIOPS.ModifyingExisting). |

### No data retrieved from Prometheus

> **Warning:** Increasing CPU or memory values for Fargate tasks are a manual task at the moment. We're looking to enable auto-scaling.

| Possible cause                                    | Monitored by | Alert                                 | Next step |
|---------------------------------------------------|--------------|---------------------------------------|-----------|
| Prometheus ECS task fails to start                | IMA Platform | Number of running tasks is below 1    | Check the logs for the latest stopped task and decide whether to rollback (by reverting the latest changes) or roll forward (fix the issue). Check the [Docker image for Prometheus](https://github.com/ministryofjustice/staff-infrastructure-metric-aggregation-server) for the latest changes. |
| SNMP exporter ECS task fails to start             | IMA Platform | Number of running tasks is below 1    | Check the logs for the latest stopped task and decide whether to rollback (by reverting the latest changes) or roll forward (fix the issue). Check the [Docker image for SNMP exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-snmpexporter) for the latest changes. |
| Blackbox ECS task fails to start                  | IMA Platform | Number of running tasks is below 1    | Check the logs for the latest stopped task and decide whether to rollback (by reverting the latest changes) or roll forward (fix the issue). Check the [Docker image for Blackbox exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-blackbox-exporter) for the latest changes. |
| Prometheus ECS service CPU utilisation is high    | IMA Platform | CPU utilisation is higher than 50%    | Increase the [Prometheus Fargate CPU value in the task definition](https://github.com/ministryofjustice/staff-infrastructure-monitoring/blob/05145d0b1208226b1317026197e814bf8068ab24/modules/prometheus/service.tf#L85). |
| Prometheus ECS service memory utilisation is high | IMA Platform | Memory utilisation is higher than 50% | Increase the [Prometheus Fargate Memory value in the task definition](https://github.com/ministryofjustice/staff-infrastructure-monitoring/blob/05145d0b1208226b1317026197e814bf8068ab24/modules/prometheus/service.tf#L86). |

## Resolving issues

When deciding to roll back or roll forward, you should consider the complexity
of the issue. If the issue is obvious, then quickly fix it and roll forward but
if it's not immediately obvious, then it might be best to try and get "green" as
quickly as possible i.e. revert back to the latest successful build and debug
the issue after the fact to minimise impact on users.

For example:

- If you found that Grafana was responding with `504 Gateway Time-out` and see
  that recently the port values are incorrect in the Grafana security groups,
  then this is easy enough to correct and roll forward.
