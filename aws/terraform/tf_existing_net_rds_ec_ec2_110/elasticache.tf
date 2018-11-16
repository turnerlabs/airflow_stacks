# Elasticache Related Items
resource "aws_elasticache_subnet_group" "airflow_ec_subnet_grp" {
  name       = "${var.prefix}-ec-subnet"
  subnet_ids = ["${var.private_subnet1_id}", "${var.private_subnet2_id}"]
}

resource "aws_elasticache_cluster" "airflow_elasticache" {
  availability_zone         = "${var.availability_zone_1}"
  cluster_id                = "${var.prefix}-cluster"
  engine                    = "redis"
  node_type                 = "${var.ec_node_type}"
  num_cache_nodes           = "${var.ec_num_cache_nodes}"
  engine_version            = "${var.ec_engine_version}"
  parameter_group_name      = "${var.ec_parameter_group_name}"
  port                      = "${var.ec_port}"
  security_group_ids        = ["${aws_security_group.airflow_ec.id}"]
  subnet_group_name         = "${aws_elasticache_subnet_group.airflow_ec_subnet_grp.id}"

  tags {
    Name            = "${var.prefix}_cluster"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}
