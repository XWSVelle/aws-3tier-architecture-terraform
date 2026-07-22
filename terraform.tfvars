#### template terraform-tfvars
sosoco_name = "sosoco_template"
sosoco_instance_type = "t3.micro"
sosoco_vm_ami = "ami-0b826bb6d96d2afe4"
sosoco_key_pair = "N-virginia-key"
sosoco_tag      = "sosoco_app_server_vm" 


#### ASG Terraform-tfvars 
sosoco_asg_name = "sosoco_web_asg"
sosoco_desired_vm_capacity = 2
sosoco_vm_max_capacity = 4
sosoco_vm_min_capacity = 1

