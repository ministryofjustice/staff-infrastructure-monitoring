output "hostname" {
  value = "${aws_alb.main.dns_name}"
}
