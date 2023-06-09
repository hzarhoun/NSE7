// Spoke VPC A 
resource "aws_vpc" "spoke-vpc-a" {
  cidr_block           = var.spokeavpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "Spoke-VPC-A"
  }
}

// Spoke VPC B
resource "aws_vpc" "spoke-vpc-b" {
  cidr_block           = var.spokebvpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "Spoke-VPC-B"
  }
}

// Security VPC
resource "aws_vpc" "secuirty-vpc" {
  cidr_block           = var.securityvpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "Security VPC"
  }
}

// Spoke A VPC Subnets

resource "aws_subnet" "public-vpc-a" {
  vpc_id            = aws_vpc.spoke-vpc-a.id
  cidr_block        = var.publicvpcacidr
  availability_zone = var.az1
  tags = {
    Name = "public-vpc-A"
  }
}

resource "aws_subnet" "tgw-landing-vpc-a" {
  vpc_id            = aws_vpc.spoke-vpc-a.id
  cidr_block        = var.tgwlandingvpca
  availability_zone = var.az1
  tags = {
    Name = "tgw-landing-vpc-A"
  }
}

// Spoke B VPC Subnets

resource "aws_subnet" "public-vpc-b" {
  vpc_id            = aws_vpc.spoke-vpc-b.id
  cidr_block        = var.publicvpcbcidr
  availability_zone = var.az1
  tags = {
    Name = "public-vpc-B"
  }
}

resource "aws_subnet" "tgw-landing-vpc-b" {
  vpc_id            = aws_vpc.spoke-vpc-b.id
  cidr_block        = var.tgwlandingvpcb
  availability_zone = var.az1
  tags = {
    Name = "tgw-landing-vpc-B"
  }
}

// Security VPC Subnets

resource "aws_subnet" "sec-vpc-public1" {
  vpc_id            = aws_vpc.secuirty-vpc.id
  cidr_block        = var.secvpcpublic1
  availability_zone = var.az1
  tags = {
    Name = "sec-vpc-public1"
  }
}

resource "aws_subnet" "sec-vpc-private1" {
  vpc_id            = aws_vpc.secuirty-vpc.id
  cidr_block        = var.secvpcprivate1
  availability_zone = var.az1
  tags = {
    Name = "sec-vpc-private1"
  }
}

resource "aws_subnet" "sec-tgw-landing1" {
  vpc_id            = aws_vpc.secuirty-vpc.id
  cidr_block        = var.sectgwlanding1
  availability_zone = var.az1
  tags = {
    Name = "sec-tgw-landing1"
  }
}

resource "aws_subnet" "sec-vpc-public2" {
  vpc_id            = aws_vpc.secuirty-vpc.id
  cidr_block        = var.secvpcpublic2
  availability_zone = var.az2
  tags = {
    Name = "sec-vpc-public2"
  }
}

resource "aws_subnet" "sec-vpc-private2" {
  vpc_id            = aws_vpc.secuirty-vpc.id
  cidr_block        = var.secvpcprivate2
  availability_zone = var.az2
  tags = {
    Name = "sec-vpc-private2"
  }
}

resource "aws_subnet" "sec-tgw-landing2" {
  vpc_id            = aws_vpc.secuirty-vpc.id
  cidr_block        = var.sectgwlanding2
  availability_zone = var.az2
  tags = {
    Name = "sec-tgw-landing2"
  }
}

resource "aws_network_interface" "sec-fgt1-port2" {
  description = "sec-fgt1-port2"
  subnet_id   = aws_subnet.sec-vpc-private1.id
  tags = {
    Name = "sec-fgt1-port2"
  }
}

resource "aws_network_interface" "sec-fgt2-port2" {
  description = "sec-fgt2-port2"
  subnet_id   = aws_subnet.sec-vpc-private2.id
  tags = {
    Name = "sec-fgt2-port2"
  }
}

// Creating Internet Gateway for Security VPC
resource "aws_internet_gateway" "security-vpc-igw" {
  vpc_id = aws_vpc.secuirty-vpc.id
  tags = {
    Name = "security-vpc-igw"
  }
}

// Creating IGW for Spokes
resource "aws_internet_gateway" "spoke-a-igw" {
  vpc_id = aws_vpc.spoke-vpc-a.id
  tags = {
    Name = "spoke-A-igw"
  }
}

resource "aws_internet_gateway" "spoke-b-igw" {
  vpc_id = aws_vpc.spoke-vpc-b.id
  tags = {
    Name = "spoke-B-igw"
  }
}

// Route Tables

resource "aws_route_table" "public-vpc-security" {
  vpc_id = aws_vpc.secuirty-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.security-vpc-igw.id
  }
  tags = {
    Name = "public-vpc-security"
  }
}

resource "aws_route_table" "private-vpc-security" {
  vpc_id = aws_vpc.secuirty-vpc.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.training-tgw.id
  }
  tags = {
    Name = "private-vpc-security"
  }
}

resource "aws_route_table" "public-vpc-a" {
  vpc_id = aws_vpc.spoke-vpc-a.id
  route {
    cidr_block = var.mypublicip
    gateway_id = aws_internet_gateway.spoke-a-igw.id
  }
  route { //added in Ex3
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.training-tgw.id
  }
  tags = {
    Name = "public-vpc-A"
  }
}

resource "aws_route_table" "public-vpc-b" {
  vpc_id = aws_vpc.spoke-vpc-b.id
  route {
    cidr_block = var.mypublicip
    gateway_id = aws_internet_gateway.spoke-b-igw.id
  }
  route { //added in Ex3
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.training-tgw.id
  }
  tags = {
    Name = "public-vpc-B"
  }
}

//Route Tables added in Ex3 for TGW landing subnets

resource "aws_route_table" "sec-tgw1" {
  vpc_id = aws_vpc.secuirty-vpc.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.sec-fgt1-port2.id
  }
  tags = {
    Name = "sec-tgw1"
  }
}

resource "aws_route_table" "sec-tgw2" {
  vpc_id = aws_vpc.secuirty-vpc.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.sec-fgt2-port2.id
  }
  tags = {
    Name = "sec-tgw2"
  }
}

// Route Tables <-> Subnets (Associations)

resource "aws_route_table_association" "public-vpc-security-association1" {
  subnet_id      = aws_subnet.sec-vpc-public1.id
  route_table_id = aws_route_table.public-vpc-security.id
}

resource "aws_route_table_association" "public-vpc-security-association2" {
  subnet_id      = aws_subnet.sec-vpc-public2.id
  route_table_id = aws_route_table.public-vpc-security.id
}

resource "aws_route_table_association" "sec-vpc-private-association1" {
  subnet_id      = aws_subnet.sec-vpc-private1.id
  route_table_id = aws_route_table.private-vpc-security.id
}

resource "aws_route_table_association" "sec-vpc-private-association2" {
  subnet_id      = aws_subnet.sec-vpc-private2.id
  route_table_id = aws_route_table.private-vpc-security.id
}

resource "aws_route_table_association" "public-vpc-a-association" {
  subnet_id      = aws_subnet.public-vpc-a.id
  route_table_id = aws_route_table.public-vpc-a.id
}

resource "aws_route_table_association" "public-vpc-b-association" {
  subnet_id      = aws_subnet.public-vpc-b.id
  route_table_id = aws_route_table.public-vpc-b.id
}

// Route Tables <-> Subnets (Associations) added in Ex3 for TGW landing subnets

resource "aws_route_table_association" "sec-tgw-landing1-association" {
  subnet_id      = aws_subnet.sec-tgw-landing1.id
  route_table_id = aws_route_table.sec-tgw1.id
}

resource "aws_route_table_association" "sec-tgw-landing2-association" {
  subnet_id      = aws_subnet.sec-tgw-landing2.id
  route_table_id = aws_route_table.sec-tgw2.id
}
