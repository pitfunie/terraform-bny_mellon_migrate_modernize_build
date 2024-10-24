Step 1: Modularize the Terraform Code

Main Terraform Configuration (main.tf):


provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

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
    Name = "FED-Critical_Application"
    Bank = "FED-Critical_Application"
  }
}

module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr
  subnet_cidrs = var.subnet_cidrs
  tags        = var.tags
}

module "security" {
  source = "./modules/security"
}

module "messaging_streaming" {
  source = "./modules/messaging_streaming"
}

module "ci_cd" {
  source = "./modules/ci_cd"
}
