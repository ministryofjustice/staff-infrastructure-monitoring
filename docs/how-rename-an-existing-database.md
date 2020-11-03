# How to rename an existing database

> Warning: Doing this will lead to a potential data loss of 30 minutes if there are users using the platform as Grafana uses the database to store its sessions.

1. [Create a snapshot of the database using the AWS Console](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateSnapshot.html)
2. Restore from the created snapshot with:
   1. The new name as the `identifier`
   2. The correct database instant type: `t2.medium`
3. Once created, modify the security group on the new database to: `pttp-${env}-ima-db-in`
4. Update the Parameter Store values for `grafana_db_name` and `grafana_db_endpoint` in each environment

```bash
aws-vault exec moj-pttp-shared-services -- aws ssm put-parameter --name "/codebuild/pttp-ci-ima-pipeline/development/grafana_db_name" \
--type SecureString \
--value "super secret" \
--overwrite

aws-vault exec moj-pttp-shared-services -- aws ssm put-parameter --name "/codebuild/pttp-ci-ima-pipeline/development/grafana_db_endpoint" \
--type SecureString \
--value "super secret" \
--overwrite
```

5. Redeploy the [pipeline in Shared Services](https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/Staff-Infrastructure-Monitoring/view?region=eu-west-2) by clicking on **Release change**
6. Once the redeployment is complete, check if the switch over worked
