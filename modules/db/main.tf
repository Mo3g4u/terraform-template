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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
}

# ******************************
# RDS Cluster - Aurora Serverless v2 (MySQL8.0)
# ******************************
resource "random_password" "rds_secret" {
  length  = 20
  special = false
}
locals {
  rds_username = "root"
  rds_dbname   = "app_db"
  rds_password = random_password.rds_secret.result
}
resource "aws_secretsmanager_secret" "rds" {
  name = "${var.project}-${var.env}-secret-rds"
}
resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = local.rds_username,
    password = local.rds_password,
    dbname   = local.rds_dbname,
    host     = aws_rds_cluster.main.endpoint
    }
  )
}
resource "aws_rds_cluster" "main" {
  cluster_identifier              = "${var.project}-${var.env}-mysql80-slv2-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.03.0"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  master_username                 = local.rds_username
  master_password                 = local.rds_password
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = aws_db_subnet_group.main.name
  skip_final_snapshot             = true
  apply_immediately               = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  backup_retention_period         = 7

  serverlessv2_scaling_configuration {
    min_capacity = var.rds_scaling_min_capacity
    max_capacity = var.rds_scaling_max_capacity
  }

}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                = 1
  cluster_identifier   = aws_rds_cluster.main.id
  identifier           = "${aws_rds_cluster.main.cluster_identifier}-serverless-${count.index}"
  engine               = "aurora-mysql"
  instance_class       = "db.serverless"
  db_subnet_group_name = aws_db_subnet_group.main.name
  publicly_accessible  = false
}

resource "aws_rds_cluster_parameter_group" "main" {
  name        = "${var.project}-${var.env}-cluster-paramgrp-rds"
  family      = "aurora-mysql8.0"
  description = "RDS cluster parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.env}-db-subnetgrp"
  subnet_ids = var.subnet_ids
}
