# Alerts for the IMA Platform

Below are the alerts currently set for the IMA Platform. They have been
sectioned by the potential problem a user could have.

Those that are monitored by the IMA Platform are provisioned through the
[Configuration GitHub repository](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config)
within the [Monitoring Platform integrations directory](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config/tree/main/integrations/monitoring_platform).

## IMA Platform i.e. Grafana is unreachable

| Possible cause                  | Monitored by    | Alert                                             |
|---------------------------------|-----------------|---------------------------------------------------|
| Grafana ECS task fails to start | IMA Platform    | Number of running tasks is below 1                |
| Grafana has no healthy hosts    | AWS CloudWatch  | Number of healthy Grafana hosts < 1 for 2 minutes |

## IMA Platform is slow

| Possible cause                                       | Monitored by | Alert                                 |
|------------------------------------------------------|--------------|---------------------------------------|
| Grafana ECS service CPU utilisation is high          | IMA Platform | CPU utilisation is higher than 50%    |
| Grafana ECS service memory utilisation is high       | IMA Platform | Memory utilisation is higher than 50% |
| Grafana database is running out of available storage | IMA Platform | Available storage space is below 5 GB |

## No data retrieved from Prometheus

| Possible cause                                    | Monitored by | Alert                                 |
|---------------------------------------------------|--------------|---------------------------------------|
| Prometheus ECS task fails to start                | IMA Platform | Number of running tasks is below 1    |
| SNMP exporter ECS task fails to start             | IMA Platform | Number of running tasks is below 1    |
| Blackbox ECS task fails to start                  | IMA Platform | Number of running tasks is below 1    |
| Prometheus ECS service CPU utilisation is high    | IMA Platform | CPU utilisation is higher than 50%    |
| Prometheus ECS service memory utilisation is high | IMA Platform | Memory utilisation is higher than 50% |
