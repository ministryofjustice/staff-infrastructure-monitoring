data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    values = ["hvm"]
    name   = "virtualization-type"
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "corsham_bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"

  monitoring                  = true
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_ids[0]
  key_name                    = aws_key_pair.corsham_bastion.key_name

  instance_initiated_shutdown_behavior = "terminate"

  vpc_security_group_ids = [
    aws_security_group.corsham_bastion.id
  ]

  tags = var.tags
}