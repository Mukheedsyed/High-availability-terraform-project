# vpc module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# create ALB security group

module "ALB_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ALB_sg"
  description = "Enable HTTP/HTTPS access on port 80/443"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP Access"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS Access"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }

  ]
}

# Create Security Group for the Web Server

module "EC2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  name    = "EC2-sg"
  vpc_id  = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Enable HTTP access on port 80 via ALB SG"
      source_security_group_id = "${module.ALB_sg.security_group_id}"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# Create Security Group for the DataBase Server

module "RDS_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  name    = "DataBase Security Group"
  vpc_id  = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Enable MySQL/Aurora access on port 3306"
      source_security_group_id = "${module.EC2_sg.security_group_id}"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# Create Security Group for the EFS Server

module "EFS_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  name    = "EFS Security Group"
  vpc_id  = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "Enable NFS access on port 2049"
      source_security_group_id = "${module.EC2_sg.security_group_id}"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# Create Security Group for the ElastiCache Server

module "ES_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  name    = "ElastiCache Security Group"
  vpc_id  = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port   = 11211
      to_port     = 11211
      protocol    = "tcp"
      description = "Enable ES access on port 11211"
      source_security_group_id = "${module.EC2_sg.security_group_id}"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}