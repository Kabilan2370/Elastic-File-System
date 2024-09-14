resource "aws_vpc" "one" {
  cidr_block               = var.cidr_block
  instance_tenancy         = "default"
  enable_dns_hostnames     = var.host_name

  tags = {
    Name = "SAM-vpc"
  }
}
# public subnet 1
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.one.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "sub-one"
  }
}
# public subnet 2
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.one.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "sub-two"
  }
}

# public subnet 3
resource "aws_subnet" "sub3" {
  vpc_id                  = aws_vpc.one.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"

  tags = {
    Name = "sub-three"
  }
}


# IG
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.one.id

  tags = {
    Name = "Gateway"
  }
}

# Route table
resource "aws_route_table" "route1" {
  vpc_id                  = aws_vpc.one.id

  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "route-one"
  }
}
# Association 
resource "aws_route_table_association" "a" {
  subnet_id                = aws_subnet.sub1.id
  route_table_id           = aws_route_table.route1.id
}

# Route table two
resource "aws_route_table" "route2" {
  vpc_id                  = aws_vpc.one.id

  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "route-two"
  }
}
# Association 
resource "aws_route_table_association" "b" {
  subnet_id                = aws_subnet.sub2.id
  route_table_id           = aws_route_table.route2.id
}

# Route table three
resource "aws_route_table" "route3" {
  vpc_id                   = aws_vpc.one.id

  route {
    cidr_block             = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "route-three"
  }
}
# Association 
resource "aws_route_table_association" "c" {
  subnet_id                 = aws_subnet.sub3.id
  route_table_id            = aws_route_table.route3.id
}


# security group
resource "aws_security_group" "public_sg" {
  name                      = "public-sg"
  description               = "Allow web and ssh traffic"
  vpc_id                    = aws_vpc.one.id

  
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
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

# Elastic load balancer

resource "aws_lb" "lb" {
  name                      = "Application"
  internal                  = false
  load_balancer_type        = "application"
  security_groups           = [aws_security_group.public_sg.id]
  
  subnet_mapping {
    subnet_id = aws_subnet.sub1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.sub2.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.sub3.id
  }
  #
  tags = {
    Environment = "Rams"
  }
}
# load balancer

 resource "aws_lb_target_group" "test" {
  name                      = "padayappa"
  port                      = 80
  protocol                  = "HTTP"
  target_type               = "instance"
  vpc_id                    = aws_vpc.one.id
}

resource "aws_lb_listener" "sh_front" {
  load_balancer_arn         = aws_lb.lb.arn
  port                      = "80"
  protocol                  = "HTTP"
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.test.arn
  }
}


# auto scalling template
resource "aws_launch_template" "foobar" {

  count                     = 3
  name_prefix               = "jbl-target"
  image_id                  = var.ami_id
  instance_type             = var.inst_type
  key_name                  = var.key_name
  user_data                 = file("$efs_data")
  tags = {
    Name = "machine1"
}

}
resource "aws_autoscaling_group" "Hukkum" {

  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.sub1.id, aws_subnet.sub2.id, aws_subnet.sub3.id]
  # attach a lb target group
  target_group_arns         = [aws_lb_target_group.test.arn]

  launch_template {
    id                      = aws_launch_template.foobar.id
    version                 = "$Latest"
  }
  

}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name    = aws_autoscaling_group.Hukkum.id
  lb_target_group_arn       = aws_lb_target_group.test.arn
}
resource "aws_autoscaling_policy" "scale_down" {

  name                      = "test_scale_down"
  autoscaling_group_name    = aws_autoscaling_group.Hukkum.name
  adjustment_type           = "ChangeInCapacity"
  scaling_adjustment        = -1
  cooldown                  = 120

}

# Elastic file system

resource "aws_efs_file_system" "efs" {
  creation_token            = "efs"
  encrypted                 = true
  throughput_mode           = "bursting"

  tags = {
    Name = "Manage-file"
  }
}

resource "aws_efs_mount_target" "target" {
  file_system_id            = aws_efs_file_system.efs.id
  subnet_id                 = aws_subnet.sub1.id
  security_groups           = [aws_security_group.public_sg.id]
  #dns_name                  = true

}



