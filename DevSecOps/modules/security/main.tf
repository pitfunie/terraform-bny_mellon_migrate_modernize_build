# Security Module (modules/security/main.tf):

resource "aws_iam_role" "example_role" {
  name               = "example-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
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
      "Action": ["s3:ListBucket", "s3:GetObject"],
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

resource "aws_cloudtrail" "example" {
  name                          = "example-trail"
  s3_bucket_name                = aws_s3_bucket.data_lake.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/cloudtrail/example-trail"
  retention_in_days = 14
  tags = var.tags
}

module "securityhub" {
  source = "terraform-aws-modules/securityhub/aws"
}

resource "aws_budgets_budget" "example" {
  name              = "example-budget"
  budget_type       = "COST"
  limit_amount      = "1000"
  limit_unit        = "USD"
  time_period_start = "2022-01-01_00:00"
  time_unit         = "MONTHLY"
}
