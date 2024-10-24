Step 2: Create Modules

VPC Module (modules/vpc/main.tf):

variable "vpc_cidr" {}
variable "subnet_cidrs" {}
variable "tags" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = var.tags
}

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
