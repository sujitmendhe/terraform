terraform {
  backend "s3"{
    key = "terraform.tfstate"
    region = "us-east-1"
    #use_lockfile = true # to use S3 native locking 1.19 version above
    dynamodb_table = "sujit"
    encrypt = true
  }
}