########## EC2 FOR LAUNCH TEMPLATE ######### 

### variablelizing the VM name
variable "sosoco_name" {
  description = "this defines the machine lunch template name that will be used by the app server in sosoco environment"
  type = string
 
} 

### variablelizing the AMI 
variable "sosoco_vm_ami" {
  description = "this defines the ami that will be used by the app server in sosoco environments"
  type = string
  
}

 

### variablelizing the Instance type
variable "sosoco_instance_type" {
  description = "this defines the instance type that will be used by the app server in sosoco environment"
  type = string
 
} 

### variablelizing the key pair 
variable "sosoco_key_pair" {
 description = "this defines the count meta argument that can be used to create multiple instances of the app server in sosoco environment"
  type = string
 
} 


### variablelizing the tag name
variable "sosoco_tag" {
  description = "this defines the tag name that will be used by the app server in sosoco environment"
  type = string
 
} 


###### AUTOSCALING GROUP SECTION ######

### variablelizing the ASG name
variable "sosoco_asg_name" {
  description = "this defines the asg name that will be used by the app server in sosoco environment"
  type = string
 
} 

### variablelizing the asg capacity max and min values
    ## desired capacity 
    variable "sosoco_desired_vm_capacity" {
  description = "this defines the maximum desired capacity that will be used by the app server in sosoco environment"
  type = number
}
    ## max value for desired capacity
variable "sosoco_vm_max_capacity" {
  description = "this defines the maximum desired capacity that will be used by the app server in sosoco environment"
  type = number
 
} 
    ## min value for desired capacity
variable "sosoco_vm_min_capacity" {
  description = "this defines the minimum desired capacity that will be used by the app server in sosoco environment"
  type = number 
} 


/* NOT NEEDED SINCE IT'S REFFERENCED ALREADY 
### variables to link ASG with TEMPLATE 
    ## variablelizing the launch template ID 
variable "sosoco_template_id" {
  description = "this defines the templatate id that will be used by the app server in sosoco environment"
  type = string
 
} 
    ## variablelizing the latest version of the template to be used each time 
variable "sosoco_template_version" {
  description = "this defines the templatate version that will be used by the app server in sosoco environment"
  type = string
  default = "$Latest"
}   */

