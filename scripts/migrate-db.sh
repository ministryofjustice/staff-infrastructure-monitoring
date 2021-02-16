#!/bin/bash
## Create a new RDS db from a snapshot in moj-pttp-dev

db_identifier="staff-infra-dw-v2-ima-db"
snapshot_identifier="staff-infra-development-ima-temp-db"
db_subnet_group="mojo-dw-ima-db-subnet-group"
vpc_security_group_ids="sg-0d407275bbec42930"
instance_size="db.t2.medium"



aws rds restore-db-instance-from-db-snapshot \
--db-instance-identifier $db_identifier \
--db-snapshot-identifier $snapshot_identifier \
--db-subnet-group-name $db_subnet_group \
--vpc-security-group-ids $vpc_security_group_ids \
--db-instance-class $instance_size \
--engine postgres

