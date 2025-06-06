provider "aws" {
  region = var.aws_region
}

# 1. ECR Repository to store Docker images
resource "aws_ecr_repository" "app_repo" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 2. IAM Role and Policy for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Policy for ECR read-only access
resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Policy for SSM read-only access
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# 3. Security Group to allow web and SSH traffic
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For production, restrict this to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. EC2 Instance Resource (this CREATES the new instance)
resource "aws_instance" "app_server" {
  # The AMI ID is now hardcoded for Ubuntu 22.04 in us-east-1.
  # If using another region, you must find the corresponding AMI ID in the EC2 Console.
  ami                    = "ami-0c55b159cbfafe1f0"

  # Instance type is set to t2.micro as requested.
  instance_type          = "t2.micro"
  
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  # User data script to install Docker on Ubuntu
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ubuntu
              EOF

  tags = {
    Name = var.project_name
  }
}

# 5. SSM Parameter to store the EC2's Public IP
resource "aws_ssm_parameter" "ec2_public_ip" {
  name        = "/${var.project_name}/ec2_public_ip"
  description = "The public IP of the EC2 instance for the Notes App"
  type        = "String"
  value       = aws_instance.app_server.public_ip
  overwrite   = true # Allows the parameter to be updated if the instance is replaced
}
