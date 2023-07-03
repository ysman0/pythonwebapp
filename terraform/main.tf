provider "aws" {
  region                   = "eu-west-2"
  shared_credentials_files = ["/Users/tf_user/.aws/creds"] # replace with your details
  profile                  = "vscode"                      # replace with your details
}



# 1 create VPC
resource "aws_vpc" "pproject_VPC" {
  cidr_block = var.VPC_network_block
  tags = {
    Name = var.tag
  }
}
# 2 create internet gateway
resource "aws_internet_gateway" "pproject_igw" {
  vpc_id = aws_vpc.pproject_VPC.id
}

# 3 Create custom route table
resource "aws_route_table" "pproject_route_table" {
  vpc_id = aws_vpc.pproject_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pproject_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.pproject_igw.id
  }
  tags = {
    Name = var.tag
  }
}

# 4 Create a Subnet
resource "aws_subnet" "pproject_subnet" {
  vpc_id            = aws_vpc.pproject_VPC.id
  cidr_block        = var.subnets[0].cidr_subblock
  availability_zone = var.availability_zone_EUWEST
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "pproject_association" {
  subnet_id      = aws_subnet.pproject_subnet.id
  route_table_id = aws_route_table.pproject_route_table.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "pproject_allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.pproject_VPC.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.yusuf_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.tag
  }
}
# 7. Create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "pprojects_web_server_nic" {
  subnet_id       = aws_subnet.pproject_subnet.id
  private_ips     = [var.webserver_privateip]
  security_groups = [aws_security_group.pproject_allow_web.id]
}

# 8. Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "pproject_webserver_ip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.pprojects_web_server_nic.id
  associate_with_private_ip = var.webserver_privateip
  depends_on                = [aws_internet_gateway.pproject_igw]
}

output "yusuf_server_public_ip" {
  value = aws_eip.pproject_webserver_ip
}



# 9. Create Ubuntu server and install/enable apache2

resource "aws_instance" "pproject_web-server-instance" {
  ami                  = var.ami
  iam_instance_profile = "s3access"
  instance_type        = var.ec2_instance_type
  availability_zone    = var.availability_zone_EUWEST
  key_name             = var.ec2_key

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.pprojects_web_server_nic.id
  }

  user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update -y
                 sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
                 sudo apt install awscli -y
                 sudo aws s3 cp  s3://yours3bucket/setup_app.sh /home/ubuntu
                 EOF
  # now remote onto the EC2 instance and excecute the script downloaded from the s3 bucket/ or in ./batch_scripts
  tags = {
    Name = var.tag
  }
}



output "yusuf_server_private_ip" {
  value = aws_instance.pproject_web-server-instance.id

}

output "yusuf_server_id" {
  value = aws_instance.pproject_web-server-instance.id
}





