
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


# ******************************
# EC2 Instance - 踏み台サーバー
# ******************************
data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "main" {
  ami                    = data.aws_ssm_parameter.amzn2_ami.value
  instance_type          = "t3.nano"
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.main.name

  # EBSのルートボリューム設定
  root_block_device {
    # ボリュームサイズ(GiB)
    volume_size = 10
    # ボリュームタイプ
    volume_type = "gp2"
    # EBSのNameタグ
    tags = {
      Name = "${var.project}-${var.env}-ebs-bastion"
    }
  }

  tags = {
    Name = "${var.project}-${var.env}-ec2-bastion"
  }
}
resource "aws_ssm_association" "main" {
  association_name = "${var.project}-${var.env}-association-bastion"
  name             = "AWS-RunShellScript"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.main.id]
  }

  parameters = {
    "commands" = <<EOF
cd /root
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
sudo yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
sudo yum remove -y mariadb-libs
sudo yum localinstall -y http://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm
sudo yum install -y mysql-community-client
EOF
  }
}

# ******************************
# IAM Role
# ******************************
resource "aws_iam_role" "main" {
  name = "${var.project}-${var.env}-role-ec2-bastion"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name = "default"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2messages:*",
            "ssm:UpdateInstanceInformation",
            "ssmmessages:*",
            "ecs:ExecuteCommand",
            "ecs:DescribeTasks"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
  path = "/"
}
# ******************************
# IAM InstanceProfile
# ******************************
resource "aws_iam_instance_profile" "main" {
  name = "${var.project}-${var.env}-instance-profile"

  role = aws_iam_role.main.name
}
