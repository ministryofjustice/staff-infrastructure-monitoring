#!/bin/bash
rds_instance=$1
aws rds delete-db-instance \
        --db-instance-identifier $rds_instance \
        --skip-final-snapshot \
        --delete-automated-backups