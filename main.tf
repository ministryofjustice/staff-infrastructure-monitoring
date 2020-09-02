terraform {
  required_version = "> 0.12.0"

  backend "s3" {
    region     = "eu-west-2"
    bucket     = "pttp-default-monitoring-tf-remote-state"
    key        = "terraform/v1/state"
    lock_table = "pttp-default-monitoring-terrafrom-remote-state-lock-dynamo"
  }
}

provider "aws" {
  version = "~> 2.52"
}

data "aws_region" "current_region" {}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.16.0"

  namespace = "pttp"
  stage     = terraform.workspace
  name      = "monitoring"
  delimiter = "-"

  tags = {
    "business-unit" = "MoJO"
    "application"   = "monitoring-and-alerting",
    "is-production" = tostring(var.is-production),
    "owner"         = var.owner-email

    "environment-name" = "global"
    "source-code"      = "https://github.com/ministryofjustice/staff-infrastructure-monitoring"
  }
}

resource "aws_s3_bucket" "pttp-iam-test-bucket-1" {
  bucket = "${module.label.id}-tf-test-bucket"
  acl    = "private"

  tags = {
    Name        = "The PTTP IAM bucket"
    Environment = "Dev"
  }
}

resource "aws_ecs_cluster" "aws-ecs-staff-monitoring-cluster" {
  name = "${module.label.id}-staff-device-development-monitoring-cluster"
}

resource "aws_ecs_service" "hello-world" {
  name                = "${module.label.id}-hello-world"
  cluster             = aws_ecs_cluster.aws-ecs-staff-monitoring-cluster.id
  task_definition     = aws_ecs_task_definition.hello-world.arn
  launch_type         = "FARGATE"
  desired_count       = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.crazy-magic-tg.arn
    container_name   = "hello-world"
    container_port   = "80"
  }

  network_configuration {
    subnets = [aws_subnet.crazy-magic-subnet.id]

    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "hello-world" {
  family                = "${module.label.id}-hello"
  container_definitions = file("task-definitions/hello-world.json")
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
}

resource "aws_subnet" "crazy-magic-subnet" {
  vpc_id     = aws_vpc.crazy-magic-vpc.id
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "crazy-magic-subnet"
  }
}

resource "aws_vpc" "crazy-magic-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${module.label.id}-crazy-magic-vpc"
  }
}

resource "aws_lb_target_group" "crazy-magic-tg" {
  name     = "${module.label.id}-crazy-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.crazy-magic-vpc.id
}

resource "aws_lb" "crazy-magic-lb" {
  name               = "${module.label.id}-crazy-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.crazy-magic-subnet.id]
}

resource "aws_internet_gateway" "crazy-magic-gw" {
  vpc_id = aws_vpc.crazy-magic-vpc.id

  tags = {
    Name = "${module.label.id}-crazy-magic-gw"
  }
}
