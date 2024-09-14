resource "aws_vpc" "virginia" {
  provider                   = aws
  cidr_block                 = var.cidr_block
  instance_tenancy           = "default"
  enable_dns_hostnames       = var.host_name
  

  tags = {
    Name = "Virginia"
  }
}

resource "aws_vpc" "mumbai" {
  provider                   = aws.ap_south
  cidr_block                 = var.cidr_block
  instance_tenancy           = "default"
  enable_dns_hostnames       = var.host_name
  
  tags = {
    Name = "Mumbai"
  }
}

resource "aws_vpc" "singapore" {
  provider                   = aws.ap_southeast
  cidr_block                 = var.cidr_block
  instance_tenancy           = "default"
  enable_dns_hostnames       = var.host_name
  

  tags = {
    Name = "Singapore"
  }
}

# public subnet 1
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.virginia.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "pub-sub-one"
  }
}

# public subnet 2
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.mumbai.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "pub-sub-two"
  }
}

# public subnet 3
resource "aws_subnet" "sub3" {
  vpc_id                  = aws_vpc.singapore.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-southeast-1a"

  tags = {
    Name = "pub-sub-three"
  }
}


# IG
resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.virginia.id

  tags = {
    Name = "Gateway"
  }
}

# IG
resource "aws_internet_gateway" "gw2" {
  vpc_id = aws_vpc.mumbai.id

  tags = {
    Name = "Gateway"
  }
}

# IG
resource "aws_internet_gateway" "gw3" {
  vpc_id = aws_vpc.singapore.id

  tags = {
    Name = "Gateway"
  }
}

# Route table
resource "aws_route_table" "route1" {
  vpc_id                  = aws_vpc.virginia.id

  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.gw1.id
  }
  tags = {
    Name = "route-table-one"
  }
}
# Association 
resource "aws_route_table_association" "a" {
  subnet_id                = aws_subnet.sub1.id
  route_table_id           = aws_route_table.route1.id
}

# Route table two
resource "aws_route_table" "route2" {
  vpc_id                  = aws_vpc.mumbai.id

  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.gw2.id
  }
  tags = {
    Name = "route-table-two"
  }
}
# Association 
resource "aws_route_table_association" "b" {
  subnet_id                = aws_subnet.sub2.id
  route_table_id           = aws_route_table.route2.id
}

# Route table three
resource "aws_route_table" "route3" {
  vpc_id                  = aws_vpc.singapore.id

  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.gw3.id
  }
  tags = {
    Name = "route-table-three"
  }
}
# Association 
resource "aws_route_table_association" "c" {
  subnet_id                = aws_subnet.sub3.id
  route_table_id           = aws_route_table.route3.id
}


# security group
resource "aws_security_group" "public_sg1" {
  name                      = "public-sg"
  description               = "Allow web and ssh traffic"
  vpc_id                    = aws_vpc.virginia.id

  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}


# security group
resource "aws_security_group" "public_sg2" {
  name                      = "public-sg"
  description               = "Allow web and ssh traffic"
  vpc_id                    = aws_vpc.mumbai.id

  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}


# security group
resource "aws_security_group" "public_sg3" {
  name                      = "public-sg"
  description               = "Allow web and ssh traffic"
  vpc_id                    = aws_vpc.singapore.id

  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

# Elastic file system

resource "aws_efs_file_system" "efs" {
  creation_token            = "efs"
  #availability_zone_id      = var.us_east
  encrypted                 = true
  throughput_mode           = "bursting"

  tags = {
    Name = "Manage-file"
  }
}

resource "aws_efs_mount_target" "target" {
  file_system_id            = aws_efs_file_system.efs.id
  subnet_id                 = aws_subnet.sub1.id
  security_groups           = [aws_security_group.public_sg1.id]
  #dns_name                  = true

}

# machine 1

resource "aws_instance" "machine1" {
  ami                           = var.ami_id
  instance_type                 = var.inst_type
  subnet_id                     = aws_subnet.sub1.id
  key_name                      = var.key
  associate_public_ip_address   = var.public_key
  security_groups               = [aws_security_group.public_sg1.id]
  user_data                     = file("efs_data.sh")
  tags = {
    Name = "Machine1"
}
}

# machine 2

resource "aws_instance" "machine2" {
  ami                           = var.ami_id
  instance_type                 = var.inst_type
  subnet_id                     = aws_subnet.sub1.id
  key_name                      = var.key
  associate_public_ip_address   = var.public_key
  security_groups               = [aws_security_group.public_sg2.id]
  user_data                     = file("efs_data.sh")
  tags = {
    Name = "Machine2"
}
}

# machine 3

resource "aws_instance" "machine3" {
  ami                           = var.ami_id
  instance_type                 = var.inst_type
  subnet_id                     = aws_subnet.sub3.id
  key_name                      = var.key
  associate_public_ip_address   = var.public_key
  security_groups               = [aws_security_group.public_sg3.id]
  user_data                     = file("efs_data.sh")
  tags = {
    Name = "Machine3"
}
}



