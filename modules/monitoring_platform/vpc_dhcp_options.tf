resource "aws_vpc_dhcp_options" "mojo_dns_resolver" {
  domain_name_servers = var.mojo_dns_ips
}

resource "aws_vpc_dhcp_options_association" "mojo_dns_resolver_association" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.mojo_dns_resolver.id
}
