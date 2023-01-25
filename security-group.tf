# Create Security Group for the Application Load Balancer
resource "aws_security_group" "alb-security-group" {
  name        = "ALB Security Group"
  description = "Enable HTTP/HTTPS access on port 80/443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security Group"
  }
}

# Create Security Group for the EC2 Instance 
resource "aws_security_group" "ec2-security-group" {
  name        = "EC2 Instance Security Group"
  description = "Enable HTTP access on port 80 via ALB SG"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTP Access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web Server Security Group"
  }
}

# Create Security Group for the DtaBase Server
resource "aws_security_group" "database-security-group" {
  name        = "DataBase Security Group"
  description = "Enable MySQL/Aurora access on port 3306"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "MySQL/Aurora Access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ec2-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DataBase Security Group"
  }
}

# Create Security Group for the EFS Server
resource "aws_security_group" "efs-security-group" {
  name        = "efs Security Group"
  description = "Enable NFS access on port 2049"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "NFS Access"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ec2-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS Security Group"
  }
}

# Create Security Group for the ElasticCache Server
resource "aws_security_group" "ElasticCache-security-group" {
  name        = "efs Security Group"
  description = "Enable NFS access on port 2049"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Custom Access"
    from_port       = 1211
    to_port         = 1211
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ec2-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS Security Group"
  }
}