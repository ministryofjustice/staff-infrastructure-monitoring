#!/bin/bash

## Replace an RDS database with a snapshot of another database

db_identifier_v1="" #identifier for the v1 database
db_identifier_v2="" #identifier for the v2 database
db_subnet_group="" #subnet group for v2 database
vpc_security_group_ids="" #VPC for v2 database
snapshot_identifier="" #name of the snapshot to temporarily be created

instance_size="db.t2.medium"

# Delete current V2 database
echo "Deleting database ${db_identifier_v2}"
aws rds delete-db-instance --db-instance-identifier $db_identifier_v2 --skip-final-snapshot
aws rds wait db-instance-deleted --db-instance-identifier $db_identifier_v2

# Create snapshot of V1 database
echo "Creating snapshot of ${db_identifier_v1}"
aws rds create-db-snapshot --db-snapshot-identifier $snapshot_identifier --db-instance-identifier $db_identifier_v1
aws rds wait db-snapshot-available --db-snapshot-identifier $snapshot_identifier

# Create new database from the snapshot in the V2 VPC
echo "Recreating database ${db_identifier_v2} from snapshot"
aws rds restore-db-instance-from-db-snapshot \
--db-instance-identifier $db_identifier_v2 \
--db-snapshot-identifier $snapshot_identifier \
--db-subnet-group-name $db_subnet_group \
--vpc-security-group-ids $vpc_security_group_ids \
--db-instance-class $instance_size \
--engine postgres

aws rds wait db-instance-available --db-instance-identifier $db_identifier_v2

# Delete the snapshot
echo "Deleting snapshot"
aws rds delete-db-snapshot --db-snapshot-identifier $snapshot_identifier
aws rds wait db-snapshot-deleted --db-snapshot-identifier $snapshot_identifier
