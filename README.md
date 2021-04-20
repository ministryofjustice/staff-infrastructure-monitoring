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
identify failures as early as possible ahead of the end users noticing and
reporting them.

- [Architecture Decision Record (ADR)](architecture-decision-record)

### Our repositories

- [IMA Platform](https://github.com/ministryofjustice/staff-infrastructure-monitoring) - to monitor MoJ infrastructure and physical devices
- [Configuration](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config) - to provision configuration for the IMA Platform
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
- [Terraform](https://www.terraform.io/) (0.14.x installed via tfenv) - to manage infrastructure 

You should also have AWS account access to at least the Dev and Shared Services AWS accounts.

### 1. Set up AWS Vault

1. Create a profile for the AWS Dev account

```
aws-vault add moj-pttp-dev
```

This will prompt you for the values of your AWS Dev account's IAM user.

2. Create a profile for the AWS Shared Services account

```
aws-vault add moj-pttp-shared-services
```

This will prompt you for the values of your AWS Shared Services account's IAM user.

3. Check you can log into AWS Management Console for an account using AWS Vault

```
aws-vault login <aws-account-name>
# For Dev: aws-vault login moj-pttp-dev
# For Shared Services: aws-vault login moj-pttp-shared-services
```

This will open up AWS Management Console in your web browser.

4. Open your AWS config file (usually found in `~/.aws/config`)
5. Add `region=eu-west-2` for both the `profile moj-pttp-dev` and the `profile moj-pttp-shared-services` workspaces to set a default region for your AWS profiles

### 2. Set up MFA on your AWS account

Multi-Factor Authentication (MFA) is required on AWS accounts in this project.
You will need to do this for both your Dev and Shared Services AWS accounts.

1. Navigate to the AWS Management Console for a given account e.g. `aws-vault login moj-pttp-dev`
2. Click on **IAM** under Security, Identity, & Compliance in Services
3. Click on **Users** under Access management in the IAM sidebar
4. Find and click on your username within the list
5. Select the **Security credentials** tab, then assign an MFA device using the **Virtual MFA device** option (follow the on-screen instructions for this step)
6. Edit your local `~/.aws/config` file with the key value pair of `mfa_serial=<iam_role_from_mfa_device>` for each of your accounts. The value for `<iam_role_from_mfa_device>` can be found in the AWS console on your IAM user details page, under **Assigned MFA device**. Ensure that you remove the text "(Virtual)" from the end of key value pair's value when you edit this file.

### 3. Set up your Terraform workspace

1. Copy `.env.example` to `.env`.

```shell
$ cp .env.example .env
```
2. Modify the `.env` file and replace `<your-shared-services-aws-vault-profile>` with `moj-pttp-shared-services` or with your current aws-vault profile for the PTTP Shared Services AWS account. And replace `<thanos-image-repository-url>` with the thanos image url which can be found on Shared Services param store.

1. Prepare your working directory for Terraform

```shell
make init
```

You will be asked to provide the path to the state file inside the bucket, for development use `terraform.development.state`.

4. Create your own personal workspace by replacing `<my-name>` with your name and running:

```
aws-vault exec moj-pttp-shared-services -- terraform workspace new <my-name>
```

5. Ensure your workspace is created by listing all available workspaces:

```
aws-vault exec moj-pttp-shared-services -- terraform workspace list
```

The current workspace you're using is indicated by an asterisk (*) in the list.

6. If you don't see your workspace selected, run:

```
aws-vault exec moj-pttp-shared-services -- terraform workspace select <my-name>
```

### 4. Verify your email address for receiving emails

1. Go to [AWS Simple Email Service's Email Addresses section](https://eu-west-2.console.aws.amazon.com/ses/home?region=eu-west-2#verified-senders-email:) under Identity Management
2. Click on **Verify a New Email Address**
3. Enter your email address and click **Verify This Email Address**

You should then receive an **Email Address Verification Request** email.

4. Click on the link provided in the email

This should update your **Verification Status** to **Verified** AWS.

### 5. Set up your own development infrastructure

1. Duplicate `terraform.tfvars.example` and rename the file to `terraform.tfvars`. This is also saved in the shared services aws accounts parameter store ([`/staff-infrastructure-monitoring/terraform.tfvars`](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/staff-infrastructure-monitoring/terraform.tfvars/description?region=eu-west-2&tab=Table)) with any shared values populated.

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
