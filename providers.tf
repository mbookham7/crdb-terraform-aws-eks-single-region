provider "aws" {

  region  = var.region_1
}

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


locals {
  cluster_name = "crdb-sr-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_eks_cluster" "crdb-cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "crdb-cluster-auth" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.crdb-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.crdb-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.crdb-cluster-auth.token
}

provider "null" {
  # Configuration options
}

provider "tls" {
  # Configuration options
}

provider "time" {
  # Configuration options
}
