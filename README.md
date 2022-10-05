[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=flat&logo=github&labelColor=32393F&label=MoJ%20Compliant&query=%24.result&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fstaff-infrastructure-monitoring)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#staff-infrastructure-monitoring "Link to report")

# Infrastructure Monitoring and Alerting Platform

## Table of contents

- [About the project](#about-the-project)
  - [Our repositories](#our-repositories)
  - [Architecture Decision Record (ADR)](#architecture-decision-record)
- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [1. Set up AWS Vault](#1-set-up-aws-vault)
  - [2. Set up MFA on your AWS account](#2-set-up-mfa-on-your-aws-account)
  - [3. Set up your Terraform workspace](#3-set-up-your-terraform-workspace)
  - [4. Verify your email address for receiving emails](#4-verify-your-email-address-for-receiving-emails)
  - [5. Set up your own development infrastructure](#5-set-up-your-own-development-infrastructure)
- [Usage](#usage)
  - [Running the code for development](#running-the-code-for-development)
- [Documentation](#documentation)
- [License](#license)

## About this repository

The Infrastructure Monitoring and Alerting (IMA) Platform aims to allow service
owners and support teams to monitor the health of the MoJ infrastructure and
identify failures as early as possible ahead of the end users
reporting them. For alerting see [this](https://github.com/ministryofjustice/staff-infrastructure-monitoring-config/#alert-manager) repository.

### Our repositories

- [IMA Platform Infrastructure](https://github.com/ministryofjustice/staff-infrastructure-monitoring) - to provision the infrastructure that the IMA Platfrom is deployed on
- [Configuration](https://github.com/ministryofjustice/staff-infrastructure-monitoring-config) - to provision dashboards, alerts, and datasources that monitor MoJ infrastructure and physical devices on the IMA Platform
- [Deployments](https://github.com/ministryofjustice/staff-infrastructure-monitoring-deployments) - to deploy the IMA Platform's core services onto our infrastructure
- [SNMP Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-snmpexporter) - to scrape data from physical devices (Docker image)
- [Blackbox Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-blackbox-exporter) - to probe endpoints over HTTP, HTTPS, DNS, TCP and ICMP.s (Docker image)
- [Metric Aggregation Server](https://github.com/ministryofjustice/staff-infrastructure-metric-aggregation-server) - to pull data from the SNMP exporter (Docker image)
- [Shared Services Infrastructure](https://github.com/ministryofjustice/staff-device-shared-services-infrastructure) - to manage our CI/CD pipelines

## Getting started

### Prerequisites

Before you start you should ensure that you have installed the following:

- [AWS Command Line Interface (CLI)](https://aws.amazon.com/cli/) - to manage AWS services
- [AWS Vault](https://github.com/99designs/aws-vault) (>= 6.0.0) - to easily manage and switch between AWS account profiles on the command line
- [tfenv](https://github.com/tfutils/tfenv) - to easily manage and switch versions Terraform versions
- [Terraform](https://www.terraform.io/) (1.1.x installed via tfenv) - to manage infrastructure

You should also have AWS account access to at least the Dev and Shared Services AWS accounts.

## Authenticate with AWS

Terraform is run locally in a similar way to how it is run on the build pipelines.

It assumes an IAM role defined in the Shared Services, and targets the AWS account to gain access to the Development environment.
This is done in the Terraform AWS provider with the `assume_role` configuration.

Authentication is made with the Shared Services AWS account, which then assumes the role into the target environment.

Assuming you have been granted necessary access permissions to the Shared Service Account, please follow the CloudOps best practices provided [step-by-step guide](https://ministryofjustice.github.io/cloud-operations/documentation/team-guide/best-practices/use-aws-sso.html#re-configure-aws-vault) to configure your AWS Vault and AWS Cli with AWS SSO.

## Prepare the variables

1. Copy `.env.example` to `.env`
1. Modify the `.env` file and provide values for variables as below:

| Variables             | How?                                                                                                                                                                                                                                              |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AWS_PROFILE=`        | your **AWS-CLI** profile name for the **Shared Services** AWS account. Check [this guide](https://ministryofjustice.github.io/cloud-operations/documentation/team-guide/best-practices/use-aws-sso.html#re-configure-aws-vault) if you need help. |
| `AWS_DEFAULT_REGION=` | `eu-west-2`                                                                                                                                                                                                                                       |
| `ENV=`                | your unique terraform workspace name. :bell:                                                                                                                                                                                                      |

| :bell: HELP                                                                                                            |
| :--------------------------------------------------------------------------------------------------------------------- |
| See [Create Terraform workspace](#create-terraform-workspace) section to find out how to create a terraform workspace! |

## Initialize your Terraform

```shell
make init
```

## Switch to an isolated workspace

If you do not have a Terraform workspace created already, use the command below to create a new workspace.

### Create Terraform workspace

```shell
AWS_PROFILE=mojo-shared-services-cli terraform workspace new "YOUR_UNIQUE_WORKSPACE_NAME"
```

This should create a new workspace and select that new workspace at the same time.

> If you already have a workspace created use the command below to select the right workspace before continue.
>
> ### View Terraform workspace list
>
> ```shell
> AWS_PROFILE=mojo-shared-services-cli terraform workspace list
> ```
>
> ### Select a Terraform workspace
>
> ```shell
> AWS_PROFILE=mojo-shared-services-cli terraform workspace select "YOUR_WORKSPACE_NAME"
> ```

### 4. Verify your email address for receiving emails

1. Go to [AWS Simple Email Service's Email Addresses section](https://eu-west-2.console.aws.amazon.com/ses/home?region=eu-west-2#verified-senders-email:) under Identity Management
2. Click on **Verify a New Email Address**
3. Enter your email address and click **Verify This Email Address**

You should then receive an **Email Address Verification Request** email.

4. Click on the link provided in the email

This should update your **Verification Status** to **Verified** AWS.

### 5. Set up your own development infrastructure

1. Run `make generate-tfvars`. This will pull down the tfvars file from aws parameter store, there are some values you'll have to complete yourself, or replace placeholders with your workspace name.

```
$ cp terraform.tfvars.example terraform.tfvars
```

2. Set values for all the variables with `grafana_db_name` and `grafana_db_endpoint` set to `foo` for now. These values will be set after creating your own infrastructure.

3. Create your infrastructure by running:

```
$ make apply
```

4. Move into the `database` directory and initialise Terraform using:

```
$ cd database/ && aws-vault exec moj-pttp-dev -- terraform init
```

5. Duplicate `terraform.tfvars.example` and rename the file to `terraform.tfvars`

```
$ cp terraform.tfvars.example terraform.tfvars
```

You will find the values for these `tfvars` outputted in the console after running the command in step 3

6. Set values for all the variables using the Terraform outputs from creating your infrastructure in Step 1
7. Create your database by running:

```
$ aws-vault exec moj-pttp-dev -- terraform apply
```

8. Move back into the root directory

```
$ cd ../
```

9. Update your `terraform.tfvars` values for `grafana_db_name` and `grafana_db_endpoint` to what is outputted by Terraform at Step 5
10. Apply your changes by running:

```
$ aws-vault exec moj-pttp-shared-services -- terraform apply
```

This will enable you to use Grafana but not Prometheus, blackbox exporter and
SNMP exporter. You'll need to push a Docker image to the corresponding AWS ECR
repository that this repository created in order to utilise those components.
To do so, see the README for each:

- [SNMP Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-snmpexporter)
- [Blackbox Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-blackbox-exporter)
- [Metric Aggregation Server](https://github.com/ministryofjustice/staff-infrastructure-metric-aggregation-server) (Prometheus)

11. Before you move onto any other repo's run the following to export your terraform outputs to parameter store:

```
$ export ENV=<your-workspace-name>
$ aws-vault exec moj-pttp-shared-services -- ./scripts/publish_terraform_outputs.sh
```

## Usage

### Running the code for development

To create an execution plan:

```
$ make plan
```

To execute changes:

```
$ make apply
```

To execute changes that require a longer session e.g. creating a database:

```
$ aws-vault clear && aws-vault exec moj-pttp-shared-services --duration=2h -- terraform apply
```

To minimise costs and keep the environment clean, regularly run teardown in your workspace using:

```
$ make destroy
```

To view your changes within the AWS Management Console:

> Note: Login is into the Dev AWS account even though infrastructure execution is completed using `moj-pttp-shared-services` as it assumes the role of Dev.

```
$ aws-vault login moj-pttp-dev
```

To run Selenium tests, use:

```
$ make test
```

## Documentation

For documentation, see our [docs](/docs).

## License

[MIT License](LICENSE)
