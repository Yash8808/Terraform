
//VPC
resource "aws_vpc" "this" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "assesment-vpc"
  }
}


//Public Subnets
resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = local.azs[count.index]

  tags = {
    Name = "public-${count.index + 1}"
    Tier = "Public"
  }
}


//Private Subnets
resource "aws_subnet" "private" {
  count = length(local.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.${count.index + length(local.azs) + 1}.0/24"
  availability_zone = local.azs[count.index]

  tags = {
    Name = "private-${count.index + 1}"
    Tier = "Private"
  }
}



//Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "ig"
  }
}



//Elastic IP
resource "aws_eip" "eip-1" {
  domain = "vpc"
}



//NAT Gateway
resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.eip-1.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "ng"
  }
}



//Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "public"
  }
}



//Public Route Table Association
resource "aws_route_table_association" "public-association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}



//Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ng.id
  }
  tags = {
    Name = "private"
  }
}



//Private Route Table Association
resource "aws_route_table_association" "private-association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}



//EIC Security Group
resource "aws_security_group" "eic-sg" {
  name        = "EIC-SG"
  description = "Security group for EIC endpoint"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EIC-SG"
  }
}



//EIC Endpoint (connect to private instance)
resource "aws_ec2_instance_connect_endpoint" "eic" {
  subnet_id          = aws_subnet.private[0].id
  preserve_client_ip = false
  security_group_ids = [aws_security_group.eic-sg.id]
  tags = {
    Name = "assesment-eic"
  }
}
