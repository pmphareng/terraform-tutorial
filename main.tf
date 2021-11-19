provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

variable "subnet_prefix" {
  description = "cidr block for the subnet"
}



resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = var.subnet_prefix[0].cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = var.subnet_prefix[1].cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_prefix[1].name
  }
}





# # Extra commands
# # terraform state list
# # terraform state show <object>


# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 3.0"
#     }
#   }
# }

# # Configure the AWS Provider
# provider "aws" {
#   region     = "us-east-2"
#   access_key = ""
#   secret_key = ""
# }

# # Create a key pair in ec2

# # 1. Create a vpc
# resource "aws_vpc" "prod-vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "production"
#   }
# }

# # 2. Create an internet gateway
# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.prod-vpc.id
#   tags = {
#     Name = "production"
#   }
# }

# # 3. Create custom route table
# resource "aws_route_table" "prod-route-table" {
#   vpc_id = aws_vpc.prod-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   route {
#     ipv6_cidr_block = "::/0"
#     gateway_id      = aws_internet_gateway.gw.id
#   }

#   tags = {
#     Name = "production"
#   }
# }

# # 4. Create a subnet
# resource "aws_subnet" "prod-subnet" {
#   vpc_id            = aws_vpc.prod-vpc.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = "us-east-2a"

#   tags = {
#     Name = "production"
#   }
# }

# # 5. Associate subnet with Route Table
# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.prod-subnet.id
#   route_table_id = aws_route_table.prod-route-table.id
# }

# # 6. Create Security Group to allow port 22,80,443
# resource "aws_security_group" "allow_web" {
#   name        = "allow_web_traffic"
#   description = "Allow Web inbound traffic"
#   vpc_id      = aws_vpc.prod-vpc.id

#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
#   }

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
#   }

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "allow_web"
#   }
# }

# # 7. Create a network interface with an ip in the subnet that was created in step 4
# resource "aws_network_interface" "web-server-nic" {
#   subnet_id       = aws_subnet.prod-subnet.id
#   private_ips     = ["10.0.1.50"]
#   security_groups = [aws_security_group.allow_web.id]

#   #   attachment {
#   #     instance     = aws_instance.test.id
#   #     device_index = 1
#   #   }
# }

# # 8. Assign an elastic IP to the network interface created in step 7
# resource "aws_eip" "one" {
#   vpc                       = true
#   network_interface         = aws_network_interface.web-server-nic.id
#   associate_with_private_ip = "10.0.1.50"
#   depends_on = [
#     aws_internet_gateway.gw
#   ]
# }

# output "server_public_ip" {
#   value = aws_eip.one.public_ip
# }

# # 9. Create Ubuntu server and install/enable apache2
# resource "aws_instance" "web" {
#   ami               = "ami-020db2c14939a8efb"
#   instance_type     = "t2.micro"
#   availability_zone = "us-east-2a"
#   key_name          = "main-key"

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.web-server-nic.id
#   }

#   user_data = <<-EOF
#                 #!/bin/bash
#                 sudo apt update -y
#                 sudo apt install apache2 -y
#                 sudo systemctl start apache2
#                 sudo bash -c 'echo your very first web server > /var/www/html/index.html'
#                 EOF
#   tags = {
#     Name = "production-server"
#   }
# }
