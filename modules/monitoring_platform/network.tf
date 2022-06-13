terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.75.0"
    }
  }
}

data "aws_availability_zones" "zones" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags                 = var.tags
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.zones.names[count.index]

  tags = var.tags
}
resource "aws_subnet" "public" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.zones.names[count.index]

  map_public_ip_on_launch = true

  tags = var.tags
}

# IGW for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route network services VPC through the TGW
resource "aws_route" "network_services" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.network_services_cidr_block
}

# Route MoJO DNS VPC traffic through the TGW
resource "aws_route" "mojo_dns_1" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = "${var.mojo_dns_ip_1}/32"
}

resource "aws_route" "mojo_dns_2" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = "${var.mojo_dns_ip_2}/32"
}

# Route Blackbox DNS probes through the TGW

resource "aws_route" "dom1_dns_1" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = "${var.dom1_dns_range_1}/24"
}

resource "aws_route" "dom1_dns_2" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = "${var.dom1_dns_range_2}/24"
}

resource "aws_route" "quantum_dns_1" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = "${var.quantum_dns_range_1}/24"
}

resource "aws_route" "quantum_dns_2" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = "${var.quantum_dns_range_2}/24"
}

resource "aws_route" "quantum_dns_3" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = "${var.quantum_dns_ip_1}/32"
}

resource "aws_route" "quantum_dns_4" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = "${var.quantum_dns_ip_2}/32"
}

# Route PSN traffic through the TGW
resource "aws_route" "psn_route_1" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.psn_team_protected_range_1
}

# Route PSN VPC traffic through the TGW
resource "aws_route" "psn_route_2" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.psn_team_protected_range_2
}

# Route SOP OCI traffic through the TGW
resource "aws_route" "sop_oci" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.sop_oci_range
}

# Route Corsham 5260 traffic through the TGW
resource "aws_route" "corsham_5260" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.corsham_5260_ip
}

# Route Farnham 5260 traffic through the TGW
resource "aws_route" "farnborough_5260" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.farnborough_5260_ip
}

# Route Corsham mgmt traffic through the TGW
resource "aws_route" "corsham_mgmt" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.corsham_mgmt_range
}

# Route Farnborough mgmt traffic through the TGW
resource "aws_route" "farnborough_mgmt" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = aws_vpc.main.main_route_table_id
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.farnborough_mgmt_range
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "gw" {
  vpc        = true
  count      = var.az_count
  depends_on = [aws_internet_gateway.gw]

  tags = var.tags
}

resource "aws_nat_gateway" "gw" {
  count         = var.az_count
  allocation_id = element(aws_eip.gw.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = var.tags
}

# Create a new route table for the private subnets
# And make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }

  tags = var.tags
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

