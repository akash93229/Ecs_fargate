resource "aws_db_subnet_group" "strapi_db_subnet" {
  name       = "akash-strapi-db-subnet-group"
  subnet_ids = local.subnets

  tags = {
    Name = "akash-strapi-db-subnet-group"
  }
}

resource "aws_db_instance" "akash_strapi_postgres" {
  identifier             = "akash-strapi-postgres"
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  storage_encrypted      = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.strapi_db_subnet.name

  skip_final_snapshot    = true
  deletion_protection    = false
  backup_retention_period = 7

  tags = {
    Name = "akash-strapi-postgres-rds"
  }
}