#####################################
# AWS Infrastructure                #
#####################################

# Create VPC

resource "aws_vpc" "main" {
  cidr_block = var.location_1_vnet_address_space

  tags = {
    Name = "main"
  }
}

# Create Internete Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

# Create Subnets

resource "aws_subnet" "location_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.location_1_subnet
  availability_zone = var.location_1

  tags = {
    "Name"                            = "location_1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks_cluster"      = "owned"
  }
}

resource "aws_subnet" "location_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.location_2_subnet
  availability_zone = var.location_2

  tags = {
    "Name"                            = "location_2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks_cluster"      = "owned"
  }
}

resource "aws_subnet" "location_1_public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.location_1_public_subnet
  availability_zone       = var.location_1
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "location_1_public_subnet"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/eks_cluster" = "owned"
  }
}

resource "aws_subnet" "location_2_public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.location_2_public_subnet
  availability_zone       = var.location_2
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "location_2_public_subnet"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/eks_cluster" = "owned"
  }
}

# Create NAT Gateway

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.location_2_public_subnet.id

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Create Routes

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "location_1" {
  subnet_id      = aws_subnet.location_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "location_2" {
  subnet_id      = aws_subnet.location_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "location_1_public_subnet" {
  subnet_id      = aws_subnet.location_1_public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "location_2_public_subnet" {
  subnet_id      = aws_subnet.location_2_public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Create EKS Cluster

resource "aws_iam_role" "eks_cluster" {
  name = var.eks_cluster_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.location_1.id,
      aws_subnet.location_2.id,
      aws_subnet.location_2_public_subnet.id,
      aws_subnet.location_2_public_subnet.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster-AmazonEKSClusterPolicy]
}

# Create Node Pool

resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eks_pool_name
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.location_1.id,
    aws_subnet.location_2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = var.eks_vm_size

  scaling_config {
    desired_size = var.eks_node_count
    max_size     = 5
    min_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}
