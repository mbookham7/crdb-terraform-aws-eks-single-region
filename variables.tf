variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "region_1" {
  description = "The AWS Region in which all resources in this example should be provisioned"
}

variable "location_1" {
  description = "First Avalibility Zone"
}

variable "location_2" {
  description = "Second Avalibility Zone"
}

variable "location_1_vnet_address_space" {
  description = "The AWS VNET address space for first location"
  default = "10.2.0.0/16"
}


variable "location_1_subnet" {
  description = "The EKS pod address space for first location"
  default = "10.2.0.0/20"
}

variable "location_2_subnet" {
  description = "The EKS Service address space for first location"
  default = "10.2.16.0/20"
}

variable "location_1_public_subnet" {
  description = "The EKS pod address space for first location"
  default = "10.2.32.0/20"
}

variable "location_2_public_subnet" {
  description = "The EKS Service address space for first location"
  default = "10.2.48.0/20"
}

variable "eks_cluster_name" {
  description = "Name of the EKS CLuster"
  default = "crdb-eks-cluster"
}

variable "eks_pool_name" {
  description = "EKS Node Pool Nmae"
  default = "nodepool"
}

variable "eks_vm_size" {
  description = "Node Pool Instance Size"
  default = ["m5.xlarge"]
}

variable "eks_node_count" {
  description = "Node Pool Instance Count"
  default = 3
}

variable "cockroachdb_version" {
  description = "CockroachDB Version"
  default = "v23.1.2"
}

variable "cockroachdb_pod_cpu" {
  description = "Number of CPUs per CockroachDB Pod"
  default = "4"
}

variable "cockroachdb_pod_memory" {
  description = "Amount of Memory per CockroachDB Pod"
  default = "8Gi"
}

variable "cockroachdb_storage" {
  description = "Persistent Volume Size in GB"
  default = "50Gi"
}

variable "statfulset_replicas" {
  description = "Number of replicas in the CockraochDB StatefulSet"
  default = 3
}