resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  vpc_id              = aws_vpc.main.id
  transit_gateway_id  = var.transit_gateway_id
  subnet_ids          = aws_subnet.private.*.id

  tags = var.tags
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
}

