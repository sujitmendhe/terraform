resource "aws_key_pair" "name" {
    key_name = "task"
    public_key = file("~/.ssh/ided25519.pub")
  
}

resource "aws_instance" "name" {
    ami = "ami-0bdd88bd06d16ba03"
    instance_type = "t2.micro"
    key_name = aws_key_pair.name.key_name
  
}