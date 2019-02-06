# RDS Related Items

resource "aws_db_subnet_group" "airflow_rds_subnet_grp" {
  subnet_ids = ["${var.private_subnet1_id}", "${var.private_subnet2_id}"]

  tags {
    Name            = "${var.prefix}_rds"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_db_instance" "airflow_rds" {
  depends_on                            = ["aws_db_subnet_group.airflow_rds_subnet_grp", "aws_security_group.airflow_rds"]

  allocated_storage                     = 20
  auto_minor_version_upgrade            = true
  availability_zone                     = "${var.availability_zone_1}"
  backup_retention_period               = 5
  backup_window                         = "06:00-06:30"
  copy_tags_to_snapshot                 = true
  db_subnet_group_name                  = "${aws_db_subnet_group.airflow_rds_subnet_grp.id}"
  engine                                = "mysql"
  engine_version                        = "${var.db_engine_version}"
  iam_database_authentication_enabled   = false
  identifier                            = "${var.prefix}-${var.db_identifier}-instance"
  instance_class                        = "${var.db_instance_class}"
  parameter_group_name                  = "${var.db_parameter_group_name}"
  password                              = "${var.db_master_password}"
  port                                  = "${var.db_port}"
  publicly_accessible                   = false
  skip_final_snapshot                   = "${var.db_skip_final_snapshot}"
  storage_type                          = "gp2"
  storage_encrypted                     = true
  username                              = "${var.db_master_username}"
  vpc_security_group_ids                = ["${aws_security_group.airflow_rds.id}"]

  tags {
    Name            = "${var.prefix}-${var.db_identifier}"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}
