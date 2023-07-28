# -------------------------------------
# Terraform configuration
# -------------------------------------
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

# -------------------------------------
# Provider configuration
# -------------------------------------
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      project    = var.project
      env        = var.env
      managed_by = "terraform"
    }
  }
}

# -------------------------------------
# Network 
# -------------------------------------
module "network" {
  source             = "./modules/network"
  project            = var.project
  env                = var.env
  availability_zones = var.availability_zones
}


# -------------------------------------
# Bastion
# -------------------------------------
module "bastion" {
  source = "./modules/bastion"

  project            = var.project
  env                = var.env
  security_group_ids = [module.network.private_security_group_id]
  subnet_id          = module.network.private_subnet_ids[0]
}


# -------------------------------------
# Database
# -------------------------------------
module "db" {
  source = "./modules/db"

  project                  = var.project
  env                      = var.env
  vpc_security_group_ids   = [module.network.isolated_security_group_id]
  subnet_ids               = module.network.isolated_subnet_ids
  rds_scaling_min_capacity = var.rds_scaling_min_capacity
  rds_scaling_max_capacity = var.rds_scaling_max_capacity
}
