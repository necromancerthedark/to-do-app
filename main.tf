provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "966185979698_Admin-Account-Access"
}

terraform {
  backend "s3" {
    encrypt = true
    # cannot contain interpolations
    # bucket = "${aws_s3_bucket.terraform-state-storage-s3.bucket}"
    bucket = "the-nerd-herd-bucket"
    # region = "${aws_s3_bucket.terraform-state-storage-s3.region}"
    region = "us-east-1"
    # dynamodb_table = "example-iac-terraform-state-lock-dynamo"
    key = "terraform-state/terraform.tfstate"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "the-nerd-herd-iac-terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    name = "DynamoDB Terraform State Lock Table"
    proj = "the-nerd-herd-iac"
    env = "prod"
  }
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
    subnet_ids = [var.subnet_id,var.second_subnet_id]
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
resource "aws_eks_node_group" "the-nerd-herd-node-group" {
  cluster_name    = aws_eks_cluster.the-nerd-herd-cluster.name
  node_group_name = "the-nerd-herd-node-group"
  node_role_arn   = aws_iam_role.the-nerd-herd-role.arn
  subnet_ids      = [var.subnet_id,var.second_subnet_id]

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 1
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.the-nerd-herd-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.the-nerd-herd-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.the-nerd-herd-AmazonEC2ContainerRegistryReadOnly,
  ]
}

