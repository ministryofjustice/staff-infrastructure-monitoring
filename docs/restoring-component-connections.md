# Restoring component connections

The IMA Platform consists of a number of components:

- Grafana
- Prometheus
- SNMP Exporter
- Blackbox Exporter

In the very unlikely event that all these components are reset
e.g. all infrastructure is destroyed and connections between Grafana, Prometheus
and the exporters are lost, this guidance will outline the steps required to
restore connection between everything.

1. Run the pipeline for `staff-infrastructure-monitoring`
2. Using the Terraform outputs from CodePipeline, for each environment update
   its config file with the new SNMP and Blackbox Exporter URLs in
   `staff-infrastructure-metric-aggregator-server`:
   1. [Development](https://github.com/ministryofjustice/staff-infrastructure-metric-aggregation-server/blob/main/prometheus.development.yml)
   2. [Pre-Production](https://github.com/ministryofjustice/staff-infrastructure-metric-aggregation-server/blob/main/prometheus.pre-production.yml)
   3. [Production](https://github.com/ministryofjustice/staff-infrastructure-metric-aggregation-server/blob/main/prometheus.production.yml)
3. Run the pipeline for `staff-infrastructure-metric-aggregator-server`
   (Prometheus) to push the Docker image to the ECR repository for each
   environment
4. Run the pipeline for `staff-infrastructure-monitoring-snmpexporter`
   (SNMP Exporter) to push the Docker image to the ECR repository for each
   environment
5. Run the pipeline for `staff-infrastructure-monitoring-blackbox-exporter`
   (Blackbox Exporter) to push the Docker image to the ECR repository for each
   environment
6. Using the Terraform outputs from CodePipeline for
   `staff-infrastructure-monitoring`, update the URL for Prometheus in Parameter
   Store for each environment:
   1. `/codebuild/pttp-ci-datasource-config-pipeline/development/prometheus_data_source_url`
   2. `/codebuild/pttp-ci-datasource-config-pipeline/pre-production/prometheus_data_source_url`
   3. `/codebuild/pttp-ci-datasource-config-pipeline/production/prometheus_data_source_url`
7. Run the pipeline for `staff-infrastructure-monitoring-config` to use updated
   Prometheus URL
