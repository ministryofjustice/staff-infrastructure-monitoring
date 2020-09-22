resource "aws_db_instance" "db" {
  username                    = var.db_username
  password                    = var.db_password
  allocated_storage           = 20
  allow_major_version_upgrade = false
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  backup_retention_period     = var.db_backup_retention_period
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name
  engine                      = "postgres"
  engine_version              = "12"
  identifier                  = "${var.prefix}-db"
  instance_class              = "db.t2.medium"
  monitoring_interval         = 60
  monitoring_role_arn         = var.rds_monitoring_role_arn
  multi_az                    = true
  name                        = replace(var.prefix, "-", "")
  skip_final_snapshot         = true
  storage_encrypted           = true
  storage_type                = "gp2"
  vpc_security_group_ids      = [aws_security_group.db_in.id]

  tags = var.tags
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = var.tags
}
