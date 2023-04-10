terraform {
    /*
    cloud {
      hostname = "app.terraform.io"
      organization = "insight-catalyst"

      workspaces {
      name = "provisioners"
    }
  }*/
    required_providers {
      aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}
# data entry of the default vpc id
data "aws_vpc" "main" {
    id = "vpc-0346d582afba20e36"
}

# ssh keypair 
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWINNFV684aadJorWMKRBdJXHW5ii3PJJV8YugbtPZCizUARudZmpvi3D/LQPZyTIuVoVv+qHd73HnCRe2xVTk4up1iA9AfaoVmEdL2yhddY2y1OiptdVMj5OMtFXfNpu2/pxeKM58KV0/fZOiYcbOdD1ztms+hXjNHSfVDgtsbNJwI1VfIMY9eJRfFFhxcyUXDnoVBHeHYW41xHwbk5b2HixG9bf/klESa14xZLIfb1gGUgwSqYXE0ZQjAs5iaDm7c/bVb6O0mYcKaDpep1e+ZXMkDRVHrMowPwEiCvFHJFzNAxPoCemA6ggiUcEWXU1kxCp1lrfvta83UsUWegRYJvEefyielxBh/fEUyGGB+Pt9J4pVTs3yFfV+YE1eNQweL8vCFOuBPyLS3QSwFRZq7Ql12rwEioH6nKYrRsXm6su7gbuHEv9pmmiGN5NRXUVQrK+L5Y/Xz6CmH78tl9J9IEQi/mXxcTEFyRYzQIeW9RyWM47PEc9mhca7+j3ShZc= ebeh@EBEH-GEORGE"
}

# template file for cloud-init
data "template_file" "user_data" {
    template = file("./user_data.yaml")
}

# provisioning and ec2-user
resource "aws_instance" "web_server"{
    ami = "ami-09744628bed84e434"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.deployer.key_name}"
    vpc_security_group_ids = [aws_security_group.sg_web_server.id]
    user_data = data.template_file.user_data.rendered
    
    provisioner "file" {
    content = "mars"
    destination = "/home/ubuntu/barsoon.txt"
    connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = "${self.public_ip}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
  }

    tags = {
         Name = "web_server"
    }       
}

# security-group created
resource "aws_security_group" "sg_web_server" {
  name        = "sg_web_server"
  description = "my_web_server_sg"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["209.35.85.219/32"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
  }

}

# output the server public ip
output "public_ip" {
    value = aws_instance.web_server.public_ip
}
