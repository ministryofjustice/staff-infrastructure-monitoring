resource "aws_db_instance" "grafana" {
  allocated_storage           = 20
  monitoring_interval         = 60
  engine_version              = "12"
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  multi_az                    = true
  delete_automated_backups    = false
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${module.label.id}-db-final-snapshot"
  storage_encrypted           = true
  deletion_protection         = false
  allow_major_version_upgrade = false
  storage_type                = "gp2"
  engine                      = "postgres"
  instance_class              = "db.t2.medium"
  username                    = var.grafana_db_username
  password                    = var.grafana_db_password
  identifier                  = "${module.label.id}-db"
  monitoring_role_arn         = var.rds_monitoring_role_arn
  name                        = replace(module.label.id, "-", "")
  vpc_security_group_ids      = [var.grafana_db_in_security_group_id]
  backup_retention_period     = 7
  db_subnet_group_name        = var.grafana_db_subnet_group_name

  tags = module.label.tags
}
