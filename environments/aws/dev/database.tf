module "mysql" {
  source = "../../../modules/database"
  environment = var.environment

  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  db_instance_identifier = var.db_instance_identifier
  db_instance_type       = var.db_instance_type
  db_allocated_storage   = var.db_allocated_storage
}

resource "aws_db_instance" "mysql_instance" {
  allocated_storage    = module.mysql.db_allocated_storage
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = module.mysql.db_instance_type
  db_name              = module.mysql.db_name
  username             = module.mysql.db_username
  password             = module.mysql.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false

  vpc_security_group_ids = module.network.security_group_ids
  identifier             = var.db_instance_identifier

  tags = {
    Name = "eyelevel-metadata-server-${var.environment}"
  }
}

output "db_endpoint" {
  value = aws_db_instance.mysql_instance.endpoint
}