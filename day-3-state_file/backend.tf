terraform {
  backend "s3" {
    bucket = "shannasujit"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}