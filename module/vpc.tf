resource "aws_vpc" "elasticsearch_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "ES VPC"
  }
}

resource "aws_subnet" "elasticsearch_public_subnet" {
  vpc_id                  = aws_vpc.elasticsearch_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "ES Public Subnet"
  }
}

resource "aws_internet_gateway" "elasticsearch_ig" {
  vpc_id = aws_vpc.elasticsearch_vpc.id

  tags = {
    Name = "ES Internet Gateway"
  }
}

resource "aws_route_table" "elasticsearch_rt" {
  vpc_id = aws_vpc.elasticsearch_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.elasticsearch_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.elasticsearch_ig.id
  }

  tags = {
    Name = "ES Route Table"
  }
}

resource "aws_route_table_association" "elasticsearch_rt_association" {
  subnet_id      = aws_subnet.elasticsearch_public_subnet.id
  route_table_id = aws_route_table.elasticsearch_rt.id
}
