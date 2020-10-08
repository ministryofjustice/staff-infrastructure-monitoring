# PTTP Infrastructure Monitoring and Alerting Platform

## Table of contents

- [About the project](#about-the-project)
  - [Our repositories](#our-repositories)
- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Set up AWS Vault](#set-up-aws-vault)
  - [Set up MFA on your AWS account](#set-up-mfa-on-your-aws-account)
  - [Set up your Terraform workspace](#set-up-your-terraform-workspace)
  - [Set a default region for your AWS profiles](#set-a-default-region-for-your-aws-profiles)
  - [Create a terraform.tfvars](#create-a-terraformtfvars)
- [Usage](#usage)
  - [Running the code for development](#running-the-code-for-development)
- [License](#license)

## About the project

The Infrastructure Monitoring and Alerting (IMA) Platform aims to allow service
owners and support teams to monitor the health of the Prison Technology
Transformation Programme (PTTP) infrastructure and identify failures as early as
possible ahead of the end users noticing and reporting them. Technologies such
as [Grafana](https://grafana.com/) and [Prometheus](https://prometheus.io/) are
utilised.

### Our repositories

- [IMA Platform](https://github.com/ministryofjustice/staff-infrastructure-monitoring) - to monitor PTTP infrastructure and physical devices
- [Data Source Configuration](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config) - to provision data sources for the IMA Platform
- [SNMP Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-snmpexporter) - to scrape data from physical devices (Docker image)
- [Blackbox Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-blackbox-exporter) - to probe endpoints over HTTP, HTTPS, DNS, TCP and ICMP.s (Docker image)
- [Metric Aggregation Server](https://github.com/ministryofjustice/staff-infrastructure-metric-aggregation-server) - to pull data from the SNMP exporter (Docker image)

## Getting started

### Prerequisites

- [AWS Command Line Interface (CLI)](https://aws.amazon.com/cli/) - to manage AWS services
- [AWS Vault](https://github.com/99designs/aws-vault) - to easily manage and switch between AWS account profiles on the command line
- [tfenv](https://github.com/tfutils/tfenv) - to easily manage and switch [Terraform](https://www.terraform.io/) versions (0.12.29 is preferred)

You should also have AWS account access to at least the Dev and Shared Services AWS accounts.

### Set up AWS Vault

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

### Set up MFA on your AWS account

Multi-Factor Authentication (MFA) is required on AWS accounts in this project.
You will need to do this for both your Dev and Shared Services AWS accounts.

1. Navigate to the AWS Management Console for a given account e.g. `aws-vault login moj-pttp-dev`
2. Click on **IAM** under Security, Identity, & Compliance in Services
3. Click on **Users** under Access management in the IAM sidebar
4. Find and click on your username within the list
5. Select the **Security credentials** tab, then assign an MFA device using the **Virtual MFA device** option (follow the on-screen instructions for this step)
6. Edit your local `~/.aws/config` file with the key value pair of `mfa_serial=<iam_role_from_mfa_device>` for each of your accounts. The value for `<iam_role_from_mfa_device>` can be found in the AWS console on your IAM user details page, under **Assigned MFA device**. Ensure that you remove the text "(Virtual)" from the end of key value pair's value when you edit this file.

### Set up your Terraform workspace

1. Prepare your working directory for Terraform

```
aws-vault exec moj-pttp-shared-services -- terraform init
```
You will be asked to provited the path to the state file inside the bucket, dev convention is to use `terraform.development.state`

2. Create your own personal workspace by replacing `<my-name>` with your name and running:

```
aws-vault exec moj-pttp-shared-services -- terraform workspace new <my-name>
```

3. Ensure your workspace is created by listing all available workspaces:

```
aws-vault exec moj-pttp-shared-services -- terraform workspace list
```

The current workspace you're using is indicated by an asterisk (*) in the list.

4. If you don't see your workspace selected, run:

```
aws-vault exec moj-pttp-shared-services -- terraform workspace select <my-name>
```

### Set a default region for your AWS profiles

1. Open your AWS config file (usually found in `~/.aws/config`)
2. Add `region=eu-west-2` for both the `profile moj-pttp-dev` and the `profile moj-pttp-shared-services` workspaces

### Verify your email address for receiving emails

1. Go to [AWS Simple Email Service's Email Addresses section](https://eu-west-2.console.aws.amazon.com/ses/home?region=eu-west-2#verified-senders-email:) under Identity Management
2. Click on **Verify a New Email Address**
3. Enter your email address and click **Verify This Email Address**

You should then receive an **Email Address Verification Request** email.

4. Click on the link provided in the email

This should update your **Verification Status** to **Verified** AWS.

### Create a `terraform.tfvars`

1. Duplicate `terraform.tfvars.example` and rename the file to `terraform.tfvars`
2. Set values for all the variables

## Usage

### Running the code for development

To create an execution plan:

```
aws-vault exec moj-pttp-shared-services -- terraform plan
```

To execute changes:

```
aws-vault exec moj-pttp-shared-services -- terraform apply
```

To minimise costs and keep the environment clean, regularly run teardown in your workspace using:

```
aws-vault exec moj-pttp-shared-services -- terraform destroy
```

To view your changes within the AWS Management Console:

> Note: Login is into the Dev AWS account even though infrastructure execution is completed using `moj-pttp-shared-services` as it assumes the role of Dev.

```
aws-vault login moj-pttp-dev
```

## License

[MIT License](LICENSE)
