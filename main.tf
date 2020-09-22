#----- VPC --------
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = "${var.name}-vpc"

  cidr = var.cidr

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = [var.private_subnets[0], var.private_subnets[1]]
  public_subnets  = [var.public_subnets[0], var.public_subnets[1]]

  enable_nat_gateway = true
  create_igw         = true

  tags = {
    Environment = var.environment
    Name        = "${var.name}-vpc"
  }
}

#----- ECS --------
module "ecs" {
  source             = "./modules/ecs"
  name               = var.name
  container_insights = true
}

#----- ECS  Services--------

module "webserver" {
  source     = "./service"
  cluster_id = module.ecs.this_ecs_cluster_id
}

#----- ECS  Instance--------
module "ec2-profile" {
  source = "./modules/ecs-instance-profile"
  name   = var.name
}
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "ec2-webserver-sg" {
  name        = "ec2-webserver-sg"
  description = "Allow HTTP traffic from public"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group_rule" "public_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2-webserver-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "public_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2-webserver-sg.id
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
}

resource "aws_instance" "web" {
  ami                  = data.aws_ami.amazon_linux_ecs.id
  instance_type        = "t2.micro"
  key_name             = var.keypair
  iam_instance_profile = module.ec2-profile.this_iam_instance_profile_id
  user_data            = data.template_file.user_data.rendered
  vpc_security_group_ids = [aws_security_group.ec2-webserver-sg.id]
  subnet_id = module.vpc.public_subnets[0]
  tags = {
    Name    = "${var.name}-instance"
    Service = var.name
  }
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = "true"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    cluster_name = var.name
  }
}
