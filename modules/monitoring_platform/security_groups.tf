resource "aws_security_group" "vpc_endpoints_security_group" {
  name        = "${var.prefix}-vpc-endpoints"
  description = "Allows the ECS containers to connect to the VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = false
  }
}
