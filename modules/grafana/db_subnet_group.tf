resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.prefix_pttp}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = var.tags
}
