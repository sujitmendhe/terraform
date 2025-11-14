provider "aws" {
  
}

resource "aws_instance" "name" {
    ami = "ami-0bdd88bd06d16ba03"
    instance_type = "t2.micro"
    tags = {
      Name = "Sujit"
    }

    lifecycle {
      create_before_destroy = true
      prevent_destroy = true
      ignore_changes = [ tags ]
    }
}