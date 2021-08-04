resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private.*.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group.id]
  private_dns_enabled = true

  tags = var.tags

  depends_on = [aws_security_group.vpc_endpoints_security_group]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private.*.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group.id]
  private_dns_enabled = true

  tags = var.tags

  depends_on = [aws_security_group.vpc_endpoints_security_group]
}

resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private.*.id
  service_name        = "com.amazonaws.${var.region}.ecs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group.id]
  private_dns_enabled = true

  tags = var.tags

  depends_on = [aws_security_group.vpc_endpoints_security_group]
}

resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private.*.id
  service_name        = "com.amazonaws.${var.region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group.id]
  private_dns_enabled = true

  tags = var.tags

  depends_on = [aws_security_group.vpc_endpoints_security_group]
}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private.*.id
  service_name        = "com.amazonaws.${var.region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group.id]
  private_dns_enabled = true

  tags = var.tags

  depends_on = [aws_security_group.vpc_endpoints_security_group]
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private.*.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group.id]
  private_dns_enabled = true

  tags = var.tags

  depends_on = [aws_security_group.vpc_endpoints_security_group]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  route_table_ids = aws_route_table.private.*.id
  service_name    = "com.amazonaws.${var.region}.s3"

  tags = var.tags
}
