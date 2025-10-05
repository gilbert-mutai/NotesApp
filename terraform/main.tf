provider "aws" {
  region = var.aws_region
}

# ----------------------------
# VPC
# ----------------------------
resource "aws_vpc" "prod_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "production"
  }
}

# ----------------------------
# Subnet
# ----------------------------
resource "aws_subnet" "prod_subnet" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "prod-subnet"
  }
}

# ----------------------------
# Internet Gateway
# ----------------------------
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "prod-gw"
  }
}

# ----------------------------
# Route Table
# ----------------------------
resource "aws_route_table" "prod_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.prod_igw.id
  }

  tags = {
    Name = "prod-route-table"
  }
}

# ----------------------------
# Route Table Association
# ----------------------------
resource "aws_route_table_association" "prod_rta" {
  subnet_id      = aws_subnet.prod_subnet.id
  route_table_id = aws_route_table.prod_route_table.id
}

# ----------------------------
# Security Group
# ----------------------------
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Django App (Port 8000)"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# ----------------------------
# SSH Key Generation
# ----------------------------
resource "tls_private_key" "notes_app_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main_key" {
  key_name   = "Main-Iac-key"
  public_key = tls_private_key.notes_app_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.notes_app_key.private_key_pem
  filename        = "${path.module}/notes-app_key.pem"
  file_permission = "0600"
}

# ----------------------------
# EC2 Instance
# ----------------------------
resource "aws_instance" "web_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = aws_subnet.prod_subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_web.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main_key.key_name

  tags = {
    Name = "Web-Server"
  }
}

# ----------------------------
# Elastic IP (Persistent)
# ----------------------------
resource "aws_eip" "static_ip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.static_ip.id
  depends_on    = [aws_instance.web_server]
}


# ----------------------------
# Ansible Inventory Output
# ----------------------------
resource "local_file" "ansible_inventory" {
  content = <<EOT
  [webservers]
  ${aws_eip.static_ip.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${abspath(path.module)}/notes-app_key.pem
  EOT

  filename = "${path.module}/../ansible/inventory.ini"
}


# ----------------------------
# Outputs
# ----------------------------
output "server_static_ip" {
  value = aws_eip.static_ip.public_ip
}

output "server_private_ip" {
  value = aws_instance.web_server.private_ip
}

output "server_id" {
  value = aws_instance.web_server.id
}