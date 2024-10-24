 Define AWS providers
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

# Define variables for VPC and subnets
variable "vpc_cidr" {
  type    = string
  default = "10.16.0.0/16"
}

variable "subnet_cidrs" {
  type = list(string)
  default = [
    "10.16.0.0/20", "10.16.16.0/20", "10.16.32.0/20", "10.16.48.0/20",
    "10.16.64.0/20", "10.16.80.0/20", "10.16.96.0/20", "10.16.112.0/20",
    "10.16.128.0/20", "10.16.144.0/20", "10.16.160.0/20", "10.16.176.0/20"
  ]
}

variable "business_units" {
  type    = list(string)
  default = ["production", "development", "testing", "reserved"]
}

variable "tags" {
  type = map(string)
  default = {
    Name = "
    Bank = "BNY-Critical_Application"
  }
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = var.tags
}

# Create subnets
resource "aws_subnet" "web" {
  for_each = toset(var.subnet_cidrs)
  vpc_id   = aws_vpc.main.id
  cidr_block = each.value
  tags = merge(var.tags, { Name = "Web-Subnet" })
}

resource "aws_subnet" "reserved" {
  count = 4
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.subnet_cidrs, count.index + 8)
  tags = merge(var.tags, { Name = "Reserved-Subnet" })
}

# Load Balancer
resource "aws_lb" "frontend" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.web[*].id
}

resource "aws_lb_target_group" "frontend" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Route 53
resource "aws_route53_zone" "main" {
  name = "yourdomain.com"
}

resource "aws_route53_record" "frontend" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.yourdomain.com"
  type    = "A"
  alias {
    name                   = aws_lb.frontend.dns_name
    zone_id                = aws_lb.frontend.zone_id
    evaluate_target_health = true
  }
}

# MQTT Broker
resource "aws_mq_broker" "mqtt" {
  broker_name     = "mqtt-broker"
  engine_type     = "ActiveMQ"
  engine_version  = "5.15.6"
  deployment_mode = "SINGLE_INSTANCE"
  host_instance_type = "mq.t2.micro"

  user {
    username = "admin"
    password = "password"
  }

  logs {
    general = true
  }
}

# S3 Data Lake
resource "aws_s3_bucket" "data_lake" {
  bucket = "your-data-lake"
  tags = merge(var.tags, { Name = "DataLake" })
}

# IAM Role and Policy
resource "aws_iam_role" "example_role" {
  name               = "example-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "example_policy" {
  name   = "example-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example_attach" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.example_policy.arn
}

# Security Groups and Firewalls
resource "aws_security_group" "example_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# CloudTrail
resource "aws_cloudtrail" "example" {
  name                          = "example-trail"
  s3_bucket_name                = aws_s3_bucket.data_lake.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}

# CloudWatch
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/cloudtrail/example-trail"
  retention_in_days = 14
  tags = var.tags
}

# AWS SecurityHub
module "securityhub" {
  source = "terraform-aws-modules/securityhub/aws"
}

# AWS Budgets
resource "aws_budgets_budget" "example" {
  name              = "example-budget"
  budget_type       = "COST"
  limit_amount      = "1000"
  limit_unit        = "USD"
  time_period_start = "2022-01-01_00:00"
  time_unit         = "MONTH
