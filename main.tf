#first deploy the VPC and refer it for the rest of the project
resource "aws_vpc" "mtc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    name = "dev"
  }
}
#choose your subnet to get started with EC2
resource "aws_subnet" "mtc_public_subnet" {
  cidr_block              = "10.123.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.mtc_vpc.id
  tags = {
    name = "dev-public"
  }

}
#creating a internet gateway to get the EC2 connected to the internet 
resource "aws_internet_gateway" "mtc_internet_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id
  tags = {
    name = "dev-igw"
  }

}
#adding a route table on the pane to get connected on vpc
resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    name = "dev-public-rt"
  }

}
#creating route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_internet_gateway.id

}
#associating route table and subnet
resource "aws_route_table_association" "mtr-table-assoc" {
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_rt.id

}
#ceating the security group
resource "aws_security_group" "mtc_sg" {
  name        = "dev-sg"
  description = "dev security group"
  vpc_id      = aws_vpc.mtc_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["use your public ip"]


  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
#creating the ssh key pair to get SSH enable
resource "aws_key_pair" "mtc_auth" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")

}
#finally deploying the EC2, as the ubuntu is the default user and can use sudo without password
resource "aws_instance" "dev-node" {
  instance_type = "t2.micro"
  ami = data.aws_ami.server_ami.id
  key_name = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id = aws_subnet.mtc_public_subnet.id
  user_data = file("user-data.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    name = "dev-node"
  }
}
  
