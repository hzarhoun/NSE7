//// Deploying Fortigate Instance
//////FortiGate-1

resource "aws_instance" "fortigate-1" {
  //it will use region, architect, and license type to decide which ami to use for deployment
  ami                         = var.fgtami[var.region][var.arch][var.license_type]
  instance_type               = var.fgtsize
  availability_zone           = var.az1
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.sec-vpc-public1.id
  vpc_security_group_ids      = [aws_security_group.fortigatessecgrp.id]
  user_data = templatefile("${var.bootstrap-fgt1}", {
    type          = "${var.license_type}"
    license_file  = "${var.license}"
    adminsport    = "${var.adminsport}"
    tgw_greaddr_1 = "${aws_ec2_transit_gateway_connect_peer.connect-peer-fgt1.transit_gateway_address}"
    fgt1_port2_ip = "${aws_network_interface.sec-fgt1-port2.private_ip}"
  })

  root_block_device {
    volume_type = "standard"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }

  tags = {
    Name = "FortiGate-1"
  }
}

resource "aws_network_interface_attachment" "fgt1port2attachment" {
  instance_id          = aws_instance.fortigate-1.id
  network_interface_id = aws_network_interface.sec-fgt1-port2.id
  device_index         = 1
}

//////FortiGate-2

resource "aws_instance" "fortigate-2" {
  ami                         = var.fgtami[var.region][var.arch][var.license_type]
  instance_type               = var.fgtsize
  availability_zone           = var.az2
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.sec-vpc-public2.id
  vpc_security_group_ids      = [aws_security_group.fortigatessecgrp.id]
  user_data = templatefile("${var.bootstrap-fgt2}", {
    type          = "${var.license_type}"
    license_file  = "${var.license}"
    adminsport    = "${var.adminsport}"
    tgw_greaddr_2 = "${aws_ec2_transit_gateway_connect_peer.connect-peer-fgt2.transit_gateway_address}"
    fgt2_port2_ip = "${aws_network_interface.sec-fgt2-port2.private_ip}"

  })

  root_block_device {
    volume_type = "standard"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }

  tags = {
    Name = "FortiGate-2"
  }
}

resource "aws_network_interface_attachment" "fgt2port2attachment" {
  instance_id          = aws_instance.fortigate-2.id
  network_interface_id = aws_network_interface.sec-fgt2-port2.id
  device_index         = 1
}

// Security Group

resource "aws_security_group" "fortigatessecgrp" {
  name        = "Fortigates SecGRP"
  description = "Fortigates SecGRP"
  vpc_id      = aws_vpc.secuirty-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 541
    to_port     = 541
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Fortigates SecGRP"
  }
}


