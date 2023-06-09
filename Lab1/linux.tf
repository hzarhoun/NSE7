// Generating key pair files for both linux instances, and saving them in terrafom project folder
resource "tls_private_key" "keypair1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "linux1keypair" {
  key_name   = "linux1"
  public_key = tls_private_key.keypair1.public_key_openssh
}

resource "local_file" "linux1file" {
  filename = "${aws_key_pair.linux1keypair.key_name}.pem"
  content  = tls_private_key.keypair1.private_key_openssh
}

resource "tls_private_key" "keypair2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "linux2keypair" {
  key_name   = "linux2"
  public_key = tls_private_key.keypair2.public_key_openssh
}

resource "local_file" "linux2file" {
  filename = "${aws_key_pair.linux2keypair.key_name}.pem"
  content  = tls_private_key.keypair2.private_key_openssh
}

//// Deploying Linux Instance

resource "aws_instance" "linux1" {
  ami                         = var.amazonlinuxami
  instance_type               = var.linuxsize
  availability_zone           = var.az1
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public-vpc-a.id
  key_name                    = "linux1"
  vpc_security_group_ids      = [aws_security_group.linux1secgrp.id]
  tags = {
    Name = "Linux1"
  }
}

resource "aws_instance" "linux2" {
  ami                         = var.amazonlinuxami
  instance_type               = var.linuxsize
  availability_zone           = var.az1
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public-vpc-b.id
  key_name                    = "linux2"
  vpc_security_group_ids      = [aws_security_group.linux2secgrp.id]
  tags = {
    Name = "Linux2"
  }
}

// Security Group

resource "aws_security_group" "linux1secgrp" {
  name        = "Linux1 SecGRP"
  description = "Linux1 SecGRP"
  vpc_id      = aws_vpc.spoke-vpc-a.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Linux1 SecGRP"
  }
}

resource "aws_security_group" "linux2secgrp" {
  name        = "Linux2 SecGRP"
  description = "Linux2 SecGRP"
  vpc_id      = aws_vpc.spoke-vpc-b.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Linux2 SecGRP"
  }
}
