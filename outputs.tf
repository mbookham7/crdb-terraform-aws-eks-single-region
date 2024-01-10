### Region_1 Outputs

output "region" {
  value       = var.region_1
  description = "Amazon Region"
}

output "kubernetes_cluster_name" {
  value       = aws_eks_cluster.eks_cluster
  description = "EKS Cluster Name"
}

output "crdb_namespace_region_1" {
  value     = kubernetes_namespace_v1.ns_region_1.metadata[0].name
}