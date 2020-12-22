# Offboarding

## 1. Destroy your development environment

1. [Using the AWS Console, empty your AWS S3 buckets](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/empty-bucket.html)

In your `staff-infrastructure-monitoring` directory:

2. Change into the `database` directory and destroy your database using the long session command:

```
$ cd database
$ aws-vault clear && aws-vault exec moj-pttp-dev --duration=2h -- terraform destroy
```

3. Change back to the root directory and destroy your infrastructure by:

```
$ cd ..
$ aws-vault clear && aws-vault exec moj-pttp-shared-services --duration=2h -- terraform destroy
```

4. Switch to another workspace and delete your workspace by:

```
$ aws-vault exec moj-pttp-shared-services -- terraform workspace select default
$ aws-vault exec moj-pttp-shared-services -- terraform workspace delete <workspace-name>
```

## 2. Remove your Terraform workspace for the config repository

In your `staff-infrastructure-monitoring-config` directory:

1. Switch to another workspace and delete your workspace by:

```
$ aws-vault exec moj-pttp-shared-services -- terraform workspace select default
$ aws-vault exec moj-pttp-shared-services -- terraform workspace delete -force <workspace-name>
```

## 3. Remove your access to services

Ask someone with rights to remove your access to:

- [ ] AWS
- [ ] GitHub repositories
- [ ] Jira
- [ ] Azure AD
- [ ] IMA Platform environments
