##### LUNCH TEMPLATE #####
resource "aws_launch_template" "sosoco_template" {
  name = var.sosoco_name
  description = "a standard template for web servers" 
  # The AMI ID to use 
  image_id    = var.sosoco_vm_ami 
  # Network and Security settings 
  vpc_security_group_ids = [aws_security_group.ec2_sg.id] 
  #instance_type/ CPU/RAM 
  instance_type = var.sosoco_instance_type 

iam_instance_profile {
  arn = aws_iam_instance_profile.sosoco_instance_profile.arn
}

key_name = var.sosoco_key_pair
  #adding tags so the the instance will have a name during creation 
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.sosoco_tag
    }
  }
  
  }

##### AUTO SCALING GROUP #####
resource "aws_autoscaling_group" "sosoco_asg" {
  name                = var.sosoco_asg_name
  # How many instances do you want at all times?
  desired_capacity    = var.sosoco_desired_vm_capacity
  # What is the minimum and maximum you will allow?
  min_size            = var.sosoco_vm_min_capacity
  max_size            = var.sosoco_vm_max_capacity
  target_group_arns = [aws_lb_target_group.sosoco_alb_target_group.arn]
  # Link to your existing Launch Template
  launch_template {
    id      = aws_launch_template.sosoco_template.id
    version = "$Latest" # Always use the most recent version of the template
  }

  # Where should the instances be launched? 
  # List the IDs of your subnets (Public or Private)
  vpc_zone_identifier = [aws_subnet.sosoco_app_server1.id, aws_subnet.sosoco_app_server2.id]

  # This ensures any tags on the ASG are copied to the individual EC2 instances
  tag {
    key                 = "Name"
    value               = "sosoco_asg_instance"
    propagate_at_launch = true
  }
}











