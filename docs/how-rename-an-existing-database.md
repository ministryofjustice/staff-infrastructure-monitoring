# How to rename an existing database

> Warning: Doing this will lead to a potential data loss of 30 minutes if there are users using the platform as Grafana uses the database to store its sessions.

1. [Create a snapshot of the database using the AWS Console](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateSnapshot.html)
2. Restore from the created snapshot. The prepolulated setting will be correct except for:
   1. The new name as the `identifier`
   2. The correct database instant type: `t2.medium`
   3. The security group under additional connectivity configuration should be `pttp-${env}-ima-db-in` (you can remove the `default` group)
   4. In availability and durability: Multi-AZ deployment should be set to `Create a standby instance`
3. Update the Parameter Store values for `grafana_db_name` (found under the configuration tab for the new database) and `grafana_db_endpoint` (found under the Connectivity & security tab for the new database) in each environment

```bash
aws-vault exec moj-pttp-shared-services -- aws ssm put-parameter --name "/codebuild/pttp-ci-ima-pipeline/${env}/grafana_db_name" \
--type SecureString \
--value "super secret" \
--overwrite

aws-vault exec moj-pttp-shared-services -- aws ssm put-parameter --name "/codebuild/pttp-ci-ima-pipeline/${env}/grafana_db_endpoint" \
--type SecureString \
--value "super secret" \
--overwrite
```

5. Redeploy the [pipeline in Shared Services](https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/Staff-Infrastructure-Monitoring/view?region=eu-west-2) by clicking on **Release change**
6. Once the redeployment is complete, ensure that ECS has succesfully started services with the new configuration
