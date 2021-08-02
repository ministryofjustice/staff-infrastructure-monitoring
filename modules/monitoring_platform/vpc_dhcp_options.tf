resource "aws_vpc_dhcp_options" "mojo_dns_resolver" {
  domain_name_servers = ["10.180.80.5", "10.180.81.5"]
}

resource "aws_vpc_dhcp_options_association" "mojo_dns_resolver_association" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.mojo_dns_resolver.id
}