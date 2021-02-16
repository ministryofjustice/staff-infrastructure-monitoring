#!/bin/bash
## Create a new RDS db from a snapshot in moj-pttp-dev

db_identifier=""
snapshot_identifier=""
db_subnet_group=""
vpc_security_group_ids=""
instance_size="db.t2.medium"



aws rds restore-db-instance-from-db-snapshot \
--db-instance-identifier $db_identifier \
--db-snapshot-identifier $snapshot_identifier \
--db-subnet-group-name $db_subnet_group \
--vpc-security-group-ids $vpc_security_group_ids \
--db-instance-class $instance_size \
--engine postgres

