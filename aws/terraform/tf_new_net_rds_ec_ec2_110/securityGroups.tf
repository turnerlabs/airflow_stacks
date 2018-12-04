# Load Balancer Security Group

resource "aws_security_group" "airflow_lb" {
  name        = "${var.prefix}_lb"
  description = "Security group for access to airflow load balancer"
  vpc_id      = "${aws_vpc.airflow_vpc.id}"
  
  # This needs to be expanded to all the ip ranges.
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["${split(",", var.ingress_ips)}"]
    description     = "${var.ingress_ip_description}"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "${var.prefix}_lb"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Instance Security Group
resource "aws_security_group" "airflow_instance" {
  name        = "${var.prefix}_instance"
  description = "Security group for access to airflow server"
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.airflow_lb.id}"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion_instance.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "${var.prefix}_instance"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# RDS Security Group
resource "aws_security_group" "airflow_rds" {
  depends_on  = ["aws_security_group.airflow_instance"]

  name        = "${var.prefix}_rds"
  description = "Security group for access to rds server for airflow"
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.airflow_instance.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "${var.prefix}_rds"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Elasticache Security Group
resource "aws_security_group" "airflow_ec" {
  depends_on  = ["aws_security_group.airflow_instance"]

  name        = "${var.prefix}_ec"
  description = "Security group for access to ec server for airflow"
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.airflow_instance.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "${var.prefix}_ec"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Bastion Security Group
resource "aws_security_group" "bastion_instance" {
  name        = "${var.prefix}_bastion"
  description = "Security group for bastion access to airflow server"
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["${split(",", var.ingress_ips)}"]
    description     = "${var.ingress_ip_description}"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "${var.prefix}_bastion"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}
