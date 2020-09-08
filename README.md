# Prison Technology Transformation Program Monitoring and Alerting Platform

## Table of contents

- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Set up AWS Vault](#set-up-aws-vault)
  - [Set up MFA on your AWS account](#set-up-mfa-on-your-aws-account)
  - [Set up your Terraform workspace](#set-up-your-terraform-workspace)
  - [Set a default region for your AWS profiles](#set-a-default-region-for-your-aws-profiles)
  - [Create a terraform.tfvars](#create-a-terraformtfvars)
- [Usage](#usage)
  - [Running the code](#running-the-code)
- [License](#license)

## Getting started

### Prerequisites

- [AWS Command Line Interface (CLI)](https://aws.amazon.com/cli/) - to manage AWS services
- [AWS Vault](https://github.com/99designs/aws-vault) - to easily manage and switch between AWS account profiles on the command line
- [tfenv](https://github.com/tfutils/tfenv) - to easily manage and switch [Terraform](https://www.terraform.io/) versions

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

### Create a `terraform.tfvars`

1. Duplicate `terraform.tfvars.example` and rename the file to `terraform.tfvars`
2. Set values for all the variables

## Usage

### Running the code

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

## License

[MIT License](LICENSE)
