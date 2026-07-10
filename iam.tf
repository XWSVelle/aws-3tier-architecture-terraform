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
resource "aws_iam_instance_profile" "sosoco_instance_profile" {
  name = "sosoco_instance_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}


