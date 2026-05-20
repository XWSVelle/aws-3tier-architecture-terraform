# 1. THE ROLE (The "Hat")
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "sosoco_ec2_role"

  # 2. THE TRUST POLICY (The "Who")
  # This tells AWS: "I allow the EC2 service to wear this hat"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole" #This is the magic command that lets a service (EC2) swap its identity for this Role.
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" #This is the security check. It ensures a random Lambda or Database can't steal this role; only your EC2s can.
        }
      }
    ]
  })
}

# 3. THE POLICY (The "What" - Your S3 Rules)
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = aws_iam_role.ec2_s3_access_role.id 

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
              "s3:GetObject", # Can only download files.
              "s3:PutObject", #  Can only upload files.
              "s3:ListBucket" # Can only see the list of files in the bucket.
              ### Benefit: This is the Principle of Least Privilege. It is much safer because the EC2 can only do exactly what it needs for the application to work and nothing more.###
              
        ]
        Effect   = "Allow"
        Resource = "*"  #FIX IT TO #  Resource = [ aws_s3_bucket.sosoco_storage.arn, "${aws_s3_bucket.sosoco_storage.arn}/*"
      }
    ]
  })
}


#instance profile
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "sosoco-ec2-s3-profile"
  role = aws_iam_role.ec2_s3_access_role.name
} 

#attach the badge to the ec2 
resource "aws_instance" "sosoco_vm1" {
  ami           = " ami-xxxxxx"
  instance_type = "t3.micro" 
  # Connects it to your private subnet
  subnet_id              = aws_subnet.sosoco_app_server1.id 
  
  # Connects the security group that allows traffic from the ALB
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Recommended for private instances
  associate_public_ip_address = false
  
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name # <--- ADD THIS

  tags = {
    Name = "sosoco_machine1"
  }
}

# Attaching the badge to the second EC2 in AZ2
resource "aws_instance" "sosoco_vm2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro" 
  # Connects it to your private subnet
  subnet_id              = aws_subnet.sosoco_app_server2.id
  
  # Connects the security group that allows traffic from the ALB
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Recommended for private instances
  associate_public_ip_address = false


  tags = {
    Name = "sosoco_machine2"
  }
}

















/*# 1. create the role that will be attach to ec2 (THE ROLE) 
     # the role defines WHO can wear it (EC2)
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "sosoco_ec2_role"


# 2. this allow the ec2 service to PUT ON THE HAT
  assume_role_policy = jsonencode({
    version = "2012-10-17"
    statement = [
      {
        Action = [
          "s3:get*", "s3:put*", "s3:upload" #WRONG WRONG WRONG 
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# 3. the policy (THE RULES)
     # the policy defines WHAT they can do (access S3) 
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = aws_iam_role.ec2_s3_access_role.id # connects to the role above

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*", # This allows GetObject, but also allows GetBucketLocation, GetLifecycleConfiguration, GetBucketTagging, and about 20 other actions.
          "s3:Put*", # This allows PutObject, but also allows PutBucketPolicy, PutBucketVersioning, and PutBucketLogging.
          "s3:ListBucket"
          ##### Risk: This is less secure. You might accidentally give your EC2 permission to change the settings of the bucket itself (like making it public), when you only wanted it to upload a file.######
        ]
        Effect   = "Allow"
        Resource = "*"  # Or specifically your bucket ARN
      }
    ]
  })
}

*/


