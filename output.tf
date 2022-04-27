output "endpoint" {
  value = aws_eks_cluster.the-nerd-herd-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.the-nerd-herd-cluster.certificate_authority[0].data
}