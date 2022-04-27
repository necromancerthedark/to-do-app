provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "966185979698_PowerUser+IAM"
}

resource "aws_security_group" "the-nerd-herd-sg" {
  vpc_id = var.vpc_id
  name   = join("_", ["the-nerd-herd", "sg", var.vpc_id])
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_block"]
    }
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "The-Nerd-Herd-SG"
  }
}

resource "aws_s3_bucket" "the-nerd-herd-bucket" {
  bucket = "the-nerd-herd-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "the-nerd-herd-S3-acl" {
  bucket = aws_s3_bucket.the-nerd-herd-bucket.id
  acl    = "private"
}

resource "aws_eks_cluster" "the-nerd-herd-cluster" {
  name     = "the-nerd-herd"
  role_arn = aws_iam_role.the-nerd-herd-role.arn

  vpc_config {
    subnet_ids = [var.subnet_id]
  }

  tags = {
    Name = "The-Nerd-Herd"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.the-nerd-herd-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.the-nerd-herd-AmazonEKSVPCResourceController,
  ]
}

