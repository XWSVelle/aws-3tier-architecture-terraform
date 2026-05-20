# let's create the storage room 
resource "aws_s3_bucket" "sosoco_storage" {
  bucket = "my-sosoco-bucket" # the actual cloud name 

  tags = {
    Name        = "my-sosoco-bucket" #the human label, stiky note
    
  }
}