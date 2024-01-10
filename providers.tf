provider "aws" {
  region = var.region_1

#  assume_role {
#   role_arn    = "arn:aws:iam::337380398238:role/TerraformAdminRole"
#  }
}

data "aws_eks_cluster_auth" "default" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  alias                  = "region_1"
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
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
