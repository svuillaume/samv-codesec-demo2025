provider "aws" {
  region = "ca-central-1"
}

# 1. Public S3 bucket (intentionally public)
resource "aws_s3_bucket" "public_bucket_demo" {
  bucket = "extremely-insecure-public-bucket-demo"
  acl    = "public-read"

  tags = {
    Name        = "VulnerablePublicBucket"
    Environment = "Test1"
  }
}

resource "aws_s3_bucket_website_configuration" "public_bucket_demo_website" {
  bucket = aws_s3_bucket.public_bucket_demo.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_policy_demo" {
  bucket = aws_s3_bucket.public_bucket_demo.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.public_bucket_demo.arn}/*"
    }]
  })
}

# 2. Unencrypted S3 bucket
resource "aws_s3_bucket" "unencrypted_bucket_demo" {
  bucket = "totally-unprotected-data-bucket"

  tags = {
    Name = "NoEncryption"
  }
}

# 3. SSH-only security group
resource "aws_security_group" "open_sg_demo" {
  name        = "allow_ssh_only"
  description = "Allow SSH inbound only"
  vpc_id      = "vpc-02bb3bfffb72e11c1"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. EC2 with hardcoded root password, unencrypted disk
resource "aws_instance" "vulnerable_ec2_demo" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-017564b2267b23fae"
  vpc_security_group_ids = [aws_security_group.open_sg_demo.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "root:SuperInsecurePassword123!" | chpasswd
              EOF

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name = "InsecureEC2"
  }
}

# 5. EC2 with IMDSv1 enabled
resource "aws_instance" "ec2_with_imdsv1" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-017564b2267b23fae"
  vpc_security_group_ids = [aws_security_group.open_sg_demo.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  tags = {
    Name = "EC2WithIMDSv1"
  }
}

# 6. EC2 with hardcoded secret
resource "aws_instance" "ec2_with_secret" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-017564b2267b23fae"
  vpc_security_group_ids = [aws_security_group.open_sg_demo.id]

  user_data = <<-EOF
              #!/bin/bash
              export DB_PASSWORD="SuperSecret123"
              EOF

  tags = {
    Name = "EC2WithHardcodedSecret"
  }
}

# 7. IAM user and hardcoded access key
resource "aws_iam_user" "insecure_user_demo" {
  name = "insecure-user"
}

resource "aws_iam_access_key" "insecure_key_demo" {
  user    = aws_iam_user.insecure_user_demo.name
  pgp_key = "keybase:somekey"
}

# 8. IAM Admin role (over-privileged)
resource "aws_iam_role" "admin_role_demo" {
  name = "insecure-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "FullAdminRole"
  }
}

resource "aws_iam_role_policy_attachment" "admin_role_attachment_demo" {
  role       = aws_iam_role.admin_role_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
