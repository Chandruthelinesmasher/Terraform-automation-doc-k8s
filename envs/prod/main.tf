provider "aws" {
  region = var.aws_region
}

# VPC Module (from Phase 1)
module "vpc" {
  source = "../../modules/vpc"

  vpc_name             = "infraops-vpc-prod"
  cidr_block           = "10.0.0.0/16"
  availability_zones   = ["ap-south-1a", "ap-south-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  environment          = var.environment
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security_groups"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  cluster_name              = "infraops-eks-prod"
  cluster_version           = "1.29"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  cluster_security_group_id = module.security_groups.eks_cluster_security_group_id
  node_security_group_id    = module.security_groups.eks_nodes_security_group_id

  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 3
  node_instance_types = ["t3.medium"]

  environment = var.environment
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  identifier        = "infraops-postgres-prod"
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  
  allocated_storage = 20
  # engine_version removed - will use default from variables.tf
  instance_class    = "db.t3.micro"
  
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.rds_security_group_id
  
  backup_retention_period = 7
  multi_az                = false
  
  environment = var.environment
}
