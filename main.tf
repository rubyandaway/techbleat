terraform {
  backend "s3" {
    bucket = "bucket4state54"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
    acl = "private"
  }

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_default_vpc" "default" {

}


# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Create the key-pair
resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_path)
}

# Create the HTTPD server
resource "aws_instance" "httpd-webserver" {
  ami                    = data.aws_ssm_parameter.amazonlinux2.value
  instance_type          = var.my_instance_type
  availability_zone      = "us-east-1a"
  key_name               = ""
  vpc_security_group_ids = [aws_security_group.http-sg.id]
  user_data              = file("/scripts/httpd-server.sh")



  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }

  tags = {
    Name = "HTTPD-server"
  }

}

output "aws_instance_public_dns" {
  value = aws_instance.httpd-webserver.public_dns
}



resource "aws_db_instance" "rds-database" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = "bomaDatabase"
  username               = "benson"
  password               = "password1"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  availability_zone      = "us-east-1a"

  tags = {
    Name = "RDS-Database"
  }
}


resource "aws_instance" "python-server" {
  ami                    = data.aws_ssm_parameter.amazonlinux2.value
  instance_type          = var.my_instance_type
  availability_zone      = "us-east-1c"
  vpc_security_group_ids = [aws_security_group.python-sg.id]
  key_name               = ""
  user_data              = file("/scripts/python.sh")

  tags = {
    Name = "PYTHON-server"
  }

}


resource "aws_security_group" "ssh-sg" {
  name        = "ssh access"
  description = "Allow SSH"
  vpc_id      = aws_default_vpc.default.id


  ingress {
    description = "SSH access "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH Security group"
  }
}

resource "aws_security_group" "http-sg" {
  name        = "http access"
  description = "Allow HTTP"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "non-secure HTTP port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "secure HTTPS port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HTTP Security group"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "RDS access"
  description = "Allow RDS"
  vpc_id      = aws_default_vpc.default.id


  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "RDS Security group"
  }
}

resource "aws_security_group" "python-sg" {
  name        = "Python-server access"
  description = "Allow RDS"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Python-server Security group"
  }
}


data "aws_ssm_parameter" "amazonlinux2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}