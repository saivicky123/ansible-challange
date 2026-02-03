provider "aws" {
  region = "us-east-1"
}
# First VM: Amazon Linux
resource "aws_instance" "amazon_linux_vm" {
  ami           = "ami-0532be01f26a3de55" # Amazon Linux 2 AMI ID
  instance_type = "t3.micro"
  key_name      = "Jenkins-M2" 

  tags = {
    Name = "c8.local"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname c8.local
              EOF
}

# Second VM: Ubuntu 21.04 
resource "aws_instance" "ubuntu_vm" {
  ami           = "ami-0b6c6ebed2801a5cb" # Ubuntu 22.04 AMI ID
  instance_type = "t3.micro"
  key_name      = "Jenkins-M2"

  tags = {
    Name = "u21.local"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname u21.local
              EOF
}

output "frontend_ip" {
  value = aws_instance.amazon_linux_vm.public_ip 
}

output "backend_ip" {
  value = aws_instance.ubuntu_vm.public_ip 
}

resource "local_file" "ansible_inventory" {
  filename = "inventory.ini"
  content  = <<-EOT
    [frontend]
    c8.local ansible_host=${aws_instance.amazon_linux_vm.public_ip} ansible_user=ec2-user

    [backend]
    u21.local ansible_host=${aws_instance.ubuntu_vm.public_ip} ansible_user=ubuntu
  EOT
}
