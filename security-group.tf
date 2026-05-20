#EC2 security group created
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "sg that will manage inbound traffic and all outbound traffic at the level of the instance"
  vpc_id      = aws_vpc.sosoco_vpc.id

  tags = {
    Name = "ec2_sg"
  }
} 

#ALB security group created 
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "sg that will manage inbound traffic and all outbound traffic at the level of the ALB"
  vpc_id      = aws_vpc.sosoco_vpc.id

  tags = {
    Name = "alb_sg"
  }
}

# 1. ALB receives data from the internet 
resource "aws_vpc_security_group_ingress_rule" "alb_inbound_from_internet" {
  security_group_id            = aws_security_group.alb_sg.id
  cidr_ipv4                    = "0.0.0.0/0" 
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

# 2. ALB communicates to the EC2 
resource "aws_vpc_security_group_egress_rule" "alb_outbound_to_ec2" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.ec2_sg.id # ONLY the ALB can talk to EC2
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
} 

# 3. EC2 receives communication from ALB 
resource "aws_vpc_security_group_ingress_rule" "ec2_inbound_from_alb" {
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id # ONLY the ALB can talk to EC2
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

# 4. EC2 responding to the ALB 
resource "aws_vpc_security_group_egress_rule" "ec2_outbound_to_alb" {
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id # ONLY the ALB can talk to EC2
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

# 5. giving access to the admin to connect to the internet from the instance through ssh.
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.ec2_sg.id
  #cidr_ipv4        = "0.0.0.0/0" # This allowed anyone to access my ec2 through ssh
  cidr_ipv4         = "203.0.113.45/32" 
  from_port         = 22 
  ip_protocol       = "tcp"
  to_port           = 22
}

# 6. allowing the ec2 to access the internet as a whole though it has the port 22 open
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



