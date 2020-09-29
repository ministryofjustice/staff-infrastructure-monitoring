resource "aws_instance" "corsham_test_bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"

  vpc_security_group_ids = [
    aws_security_group.corsham_test_bastion.id
  ]

  monitoring                  = true
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_ids[0]
  key_name                    = aws_key_pair.testing_bastion_public_key_pair.key_name

  instance_initiated_shutdown_behavior = "terminate"

  tags = var.tags
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
