//Transit Gateway
resource "aws_ec2_transit_gateway" "training-tgw" {
  description                     = "training-tgw"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  amazon_side_asn                 = "64512"
  transit_gateway_cidr_blocks     = ["192.0.2.0/24"]
  tags = {
    Name = "training-tgw"
  }
}

// VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-vpc-sec-attach" {
  subnet_ids         = [aws_subnet.sec-tgw-landing1.id, aws_subnet.sec-tgw-landing2.id]
  transit_gateway_id = aws_ec2_transit_gateway.training-tgw.id
  vpc_id             = aws_vpc.secuirty-vpc.id
  dns_support        = "enable"
  tags = {
    Name = "tgw-vpc-Sec-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-vpc-a-attach" {
  subnet_ids         = [aws_subnet.tgw-landing-vpc-a.id]
  transit_gateway_id = aws_ec2_transit_gateway.training-tgw.id
  vpc_id             = aws_vpc.spoke-vpc-a.id
  dns_support        = "enable"
  tags = {
    Name = "tgw-vpc-A-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-vpc-b-attach" {
  subnet_ids         = [aws_subnet.tgw-landing-vpc-b.id]
  transit_gateway_id = aws_ec2_transit_gateway.training-tgw.id
  vpc_id             = aws_vpc.spoke-vpc-b.id
  dns_support        = "enable"
  tags = {
    Name = "tgw-vpc-B-attach"
  }
}

// TGW connect attachment
resource "aws_ec2_transit_gateway_connect" "tgw-connect" {
  transport_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-vpc-sec-attach.id
  transit_gateway_id      = aws_ec2_transit_gateway.training-tgw.id
  tags = {
    Name = "tgw-connect"
  }
}

// TGW connect peers
resource "aws_ec2_transit_gateway_connect_peer" "connect-peer-fgt1" {
  peer_address                  = aws_network_interface.sec-fgt1-port2.private_ip
  inside_cidr_blocks            = ["169.254.120.0/29"]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.tgw-connect.id
  bgp_asn                       = "64513"
  tags = {
    "Name" = "connect-peer-fgt1"
  }
}

resource "aws_ec2_transit_gateway_connect_peer" "connect-peer-fgt2" {
  peer_address                  = aws_network_interface.sec-fgt2-port2.private_ip
  inside_cidr_blocks            = ["169.254.101.0/29"]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.tgw-connect.id
  bgp_asn                       = "64514"
  tags = {
    "Name" = "connect-peer-fgt2"
  }
}
