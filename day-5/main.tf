#create vpc
resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "cust-vpc"
    }
  
}

#create subnet
resource "aws_subnet" "name" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "cust_sub-1"
    }
  
}

resource "aws_subnet" "name-2" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "cust-sub-2"
    }
  
}

#create internet gateway
resource "aws_internet_gateway" "name" {
    vpc_id = aws_vpc.name.id
  
}

#create route table
resource "aws_route_table" "name" {
    vpc_id = aws_vpc.name.id
    
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.name.id
    }
  
}

#create subnet association
resource "aws_route_table_association" "name" {
    subnet_id = aws_subnet.name.id
    route_table_id = aws_route_table.name.id
}

#create sg
resource "aws_security_group" "dev_sg" {
    
    name = "allow_tls"
    vpc_id = aws_vpc.name.id
    tags = {
        Name = "dev-sg"
    } 
    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

#create servers

resource "aws_instance" "name" {
  ami = "ami-0bdd88bd06d16ba03"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.name.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  associate_public_ip_address = true
}


#create eip
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "vpc-nat-eip"
  }
}

#create nat
resource "aws_nat_gateway" "name" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.name.id
  
}
#create route table edit route
resource "aws_route_table" "name2" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.name.id
  }
}
#create subnet association
resource "aws_route_table_association" "name2" {
    subnet_id = aws_subnet.name-2.id
    route_table_id = aws_route_table.name2.id
  
}
#create private servers