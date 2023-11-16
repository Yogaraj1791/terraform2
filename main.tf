##terraform code
provider "aws" {
  region = "ap-south-1"
  
}

resource "aws_vpc" "Test_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  
  }

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.Test_vpc.id  
  }


resource "aws_route_table" "tes_rtp" {
    vpc_id = aws_vpc.Test_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.test_igw.id

    }    
    
  }

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.Test_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1a"
    enable_resource_name_dns_a_record_on_launch = "true"
     
  }
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.Test_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"
    
  }

resource "aws_route_table_association" "rtp_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.tes_rtp.id
    
  }

resource "aws_security_group" "test_sg" {
  vpc_id = aws_vpc.Test_vpc.id
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
     egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    
    
  }

resource "aws_instance" "webapp" {
    subnet_id = aws_subnet.public_subnet.id
    ami = "ami-02e94b011299ef128"
    instance_type = "t2.micro"
    key_name = "webkey"
    vpc_security_group_ids = [ aws_security_group.test_sg.id ]
    
    tags = {
      Name = "webapp"
    }

    
  }

 
