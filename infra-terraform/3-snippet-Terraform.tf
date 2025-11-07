resource "aws_security_group" "db" {
  name        = "database-sg"
  description = "Security group for database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  identifier           = "studytube-production-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.medium"
  allocated_storage    = 100
  
  username             = "admin"
  password             = "P@ssw0rd!"
  
  publicly_accessible  = true
  storage_encrypted    = false
  
  vpc_security_group_ids = [aws_security_group.db.id]
  
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false
  
  tags = {
    Name        = "production-database"
    Environment = "production"
  }
}

resource "aws_s3_bucket" "public_assets" {
  bucket        = "studytube-public-assets"
  acl           = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_assets" {
  bucket = aws_s3_bucket.public_assets.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

output "database_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "database_password" {
  value = aws_db_instance.main.password
}
