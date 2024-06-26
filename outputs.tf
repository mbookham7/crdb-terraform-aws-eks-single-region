### Region_1 Outputs

output "region" {
  value       = var.region_1
  description = "Amazon Region"
}

output "crdb_namespace_region_1" {
  value     = kubernetes_namespace_v1.ns_region_1.metadata[0].name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}