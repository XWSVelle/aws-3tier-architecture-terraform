# VPC (network settings of sosoco)
resource "aws_vpc" "sosoco_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "sosoco_vpc"
  }
}

# public subnet 1
resource "aws_subnet" "sosoco_web_server1" {
  vpc_id     = aws_vpc.sosoco_vpc.id 
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "sosoco_web_server1"
  }
}

# public subnet 2
resource "aws_subnet" "sosoco_web_server2" {
  vpc_id     = aws_vpc.sosoco_vpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "sosoco_web_server2"
  }
}

# private subnet 1 for the app server 1 in AZ1 
resource "aws_subnet" "sosoco_app_server1" {
  vpc_id     = aws_vpc.sosoco_vpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.5.0/24"

  tags = {
    Name = "sosoco_app_server1"
  }
}

# private subnet 2 for the app server 2 in AZ2 
resource "aws_subnet" "sosoco_app_server2" {
  vpc_id     = aws_vpc.sosoco_vpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.7.0/24"

  tags = {
    Name = "sosoco_app_server2"
  }
}

# Internet Gateway (for the whole vpc connection to the internet)
resource "aws_internet_gateway" "sosoco_igw" {
  vpc_id = aws_vpc.sosoco_vpc.id

  tags = {
    Name = "sosoco_igw"
  }
} 

#creating the ELASTIC IP 
resource "aws_eip" "nat_eip1"{
    domain = "vpc"
}

# NAT gateway for the private subnet1 in AZ1 
resource "aws_nat_gateway" "sosoco_nat1" {
  connectivity_type = "public"
  allocation_id = aws_eip.nat_eip1.id
  subnet_id         = aws_subnet.sosoco_web_server1.id
}


#creating the ELASTIC IP 
resource "aws_eip" "nat_eip2"{
    domain = "vpc"
}
# NAT gateway for the private subnet2 in AZ2 
resource "aws_nat_gateway" "sosoco_nat2" {
  connectivity_type = "public"
  allocation_id = aws_eip.nat_eip2.id
  subnet_id         = aws_subnet.sosoco_web_server2.id
}

# Route Table for public subnets 
resource "aws_route_table" "sosoco_public_rt" {
  vpc_id = aws_vpc.sosoco_vpc.id 

  route {
    # 0.0.0.0/0 represents all destination IP addresses
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.sosoco_igw.id   # This is pointing the route table to the internet through IGW
  }

  tags = {
    Name = "sosoco_public_rt"
  }
} 

# Route Table for private app server1   
resource "aws_route_table" "sosoco_private_rt1" {
  vpc_id = aws_vpc.sosoco_vpc.id

  route {
    # 0.0.0.0/0 represents all destination IP addresses
    cidr_block = "0.0.0.0/0" 
    nat_gateway_id = aws_nat_gateway.sosoco_nat1.id   # This is pointing the route table to the internet through IGW
  }

  tags = {
    Name = "sosoco_private_rt1"
  }
} 

# Route Table for private app server2  
resource "aws_route_table" "sosoco_private_rt2" {
  vpc_id = aws_vpc.sosoco_vpc.id

  route {
    # 0.0.0.0/0 represents all destination IP addresses
    cidr_block = "0.0.0.0/0" 
    nat_gateway_id = aws_nat_gateway.sosoco_nat2.id   # This is pointing the route table to the internet through IGW
  }

  tags = {
    Name = "sosoco_private_rt2"
  }
} 

# associating public route table to public subnet 1 
resource "aws_route_table_association" "public_subnet1_rt_association1" {
  subnet_id      = aws_subnet.sosoco_web_server1.id
  route_table_id = aws_route_table.sosoco_public_rt.id
}

# associating public route table to public subnet 2 
resource "aws_route_table_association" "public_subnet2_rt_association2" {
  subnet_id      = aws_subnet.sosoco_web_server2.id
  route_table_id = aws_route_table.sosoco_public_rt.id
}

# associating private route table to private subnet 1 
resource "aws_route_table_association" "private_subnet1_rt_association1" {
  subnet_id      = aws_subnet.sosoco_app_server1.id
  route_table_id = aws_route_table.sosoco_private_rt1.id
} 

# associating private route table to private subnet 2 
resource "aws_route_table_association" "private_subnet2_rt_private_association2" {
  subnet_id      = aws_subnet.sosoco_app_server2.id
  route_table_id = aws_route_table.sosoco_private_rt2.id
} 

########################################################
########## TARGET GROUPS OF THE LOAD BALANCER ##########
########################################################

####### CREATE THE LOAD BALANCER FIRST ########
resource "aws_lb" "sosoco_alb" {
  name               = "sosoco-main-alb"
  internal           = false # this ,akes it internet facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.sosoco_web_server1.id, aws_subnet.sosoco_web_server2.id]

  tags = {
    Name = "sosoco_alb"
  }
}

# 1. CREATE THE WAITING ROOM; target group (it helps the ALB to target the EC2 instance)
 # By writing that block, you have defined:
resource "aws_lb_target_group" "alb_target_group" {
  name     = "app-alb-tg"  #The Name: tf-app-alb-tg
  port     = 80            # The Port & Protocol: It’s ready for web traffic on Port 80.
  protocol = "HTTP"        
  target_type =  "instance"        # The Type: instance means you plan to put EC2 machines inside.
  vpc_id   = aws_vpc.sosoco_vpc.id # The Location: It lives inside your specific sosoco_vpc

  # NEED TO ADD THE HEALTHCHECK SO THE ALB SHOULD NOT ASSUME THE SERVER IS FINE
 # The "Heartbeat" check
  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

# 2.1. PUT THE WORKERS (EC2/VM MACHINE) INSIDE THE ROOM; TG ATTACHMENT 
 # This connects your specific EC2 to your specific Target Group
resource "aws_lb_target_group_attachment" "sosoco_attachment1" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.sosoco_machine1.id 
  port             = 80
}

# 2.2. PUT THE SECOND WORKER INSIDE THE ROOM
resource "aws_lb_target_group_attachment" "sosoco_attachment2" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.sosoco_machine2.id 
  port             = 80
}


# 3. THE INSTRUCTOR THAT IS AT THE ENTRANCE OF THE ROOM: CHECKS THAT ALL INCOMING TRAFFIC COMES EXACTLY FROM PORT 80 
   # TARGET GROUP LISTNER 
resource "aws_lb_listener" "sosoco_http_listener" {
  # 1. Which Load Balancer is this instructor working for?
  load_balancer_arn = aws_lb.sosoco_alb.arn
  
  # 2. Which door is the instructor watching?
  port              = "80"
  protocol          = "HTTP"

  # 3. What is the instruction? (The "Action")
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}









