output "alb_dns_name" {
  description = "the dns name of the load balancer. "
  value       = aws_lb.sosoco_alb.dns_name
}

output "asg_name" {
  description = "the ASG name that the ALB will use"
  value       = aws_autoscaling_group.sosoco_asg.name
}

output "vpc_id" {
  description = "the vpc id that the ALB will use"
  value       = aws_vpc.sosoco_vpc.id
}

