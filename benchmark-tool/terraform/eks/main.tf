provider "aws" {
  version = "~> 2.68"
  shared_credentials_file = "/root/.aws"
  region = "${var.region}"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.cluster_name}"
  }
}

# Public subnets (for bastion, NAT gateway, external ELBs)
resource "aws_subnet" "public_subnet_one" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${var.availability_zone_one}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_two" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${var.availability_zone_two}"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

# Private subnets (for nodes)
resource "aws_subnet" "private_subnet_one" {
  availability_zone = "${var.availability_zone_one}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.3.0/24"
}

resource "aws_subnet" "private_subnet_two" {
  availability_zone = "${var.availability_zone_two}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.4.0/24"
}

# Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.cluster_name}"
  }
}

# Route table <> Internet gateway association
resource "aws_default_route_table" "route_table" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }
}
