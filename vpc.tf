provider "aws" {
  # profile = "default"
  profile = "sandbox"
  region = "${var.region}"
}

# VPC spans over multiple availability zones of a region
resource "aws_vpc" "bl-test-vpc" {
  # cidr_block provides private IP addresses to the nodes in vpc
  cidr_block = "${var.cidr_vpc}"
  tags = {
    Name = "bl-test-vpc"
  }
  # provisioner "local-exec" {
  #   command = "echo ${aws_vpc.bl-test-vpc.id} > vpc_id.txt"
  # }
}

# a subnet has its own route table and security_groups attached
# a subnet can not span over multiple availability zones
# subset of the VPC where the instances can be launched
resource "aws_subnet" "bl-test-subnet" {
  vpc_id = "${aws_vpc.bl-test-vpc.id}"
  # subnet's cidr_block should be a subset of the VPC cidr_block
  cidr_block = "${var.cidr_subnet}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "bl-test-subnet"
  }
}

# internet gateway connects instances to the internet
resource "aws_internet_gateway" "bl-test-gw" {
  vpc_id = "${aws_vpc.bl-test-vpc.id}"
  tags = {
    Name = "bl-test-gw"
  }  
}

# from terraform documentation: 
#   The default route, mapping the VPC’s CIDR block to “local”, is created implicitly 
#   and cannot be specified.
# aws_default_route_table is a resource that manages a Default VPC Routing Table. 
# It doesn’t create a new resource but adapts the existing default route table for 
# every VPC that gets created. 
# It deletes the existing entries in the default route table and configures it 
# based on the input received from Terraform.
resource "aws_default_route_table" "bl-test-route-table" {
  default_route_table_id = "${aws_vpc.bl-test-vpc.default_route_table_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.bl-test-gw.id}"
  }
  tags = {
    Name = "bl-test-route-table"
  }
}

# Security group are applied at the instance level.
# Security group restricts the inbound traffic to the instance. 
# It is stateful and hence the return traffic to the ports in the security 
# group is automatically allowed.
resource "aws_security_group" "bl-test-sg" {
  name = "bl-test-sg-allow-tls"
  vpc_id = "${aws_vpc.bl-test-vpc.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # cidr_blocks = ["${aws_vpc.bl-test-vpc.cidr_block}"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    # cidr_blocks = ["${aws_vpc.bl-test-vpc.cidr_block}"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bl-test-sg-allow-tls"
  }
}


output "vpc_id" {
  value = "${aws_vpc.bl-test-vpc.id}"
}