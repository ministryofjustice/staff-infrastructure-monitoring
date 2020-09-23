resource "aws_db_instance" "db" {
  allocated_storage           = 20
  monitoring_interval         = 60
  engine_version              = "12"
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  multi_az                    = true
  skip_final_snapshot         = true
  storage_encrypted           = true
  allow_major_version_upgrade = false
  storage_type                = "gp2"
  engine                      = "postgres"
  instance_class              = "db.t2.medium"
  username                    = var.db_username
  password                    = var.db_password
  identifier                  = "${var.prefix}-db"
  monitoring_role_arn         = var.rds_monitoring_role_arn
  name                        = replace(var.prefix, "-", "")
  vpc_security_group_ids      = [aws_security_group.db_in.id]
  backup_retention_period     = var.db_backup_retention_period
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name

  tags = var.tags
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = var.tags
}
