# this section stores the terraform state for the s3 bucket in the terraform state bucket we created in step 1.
terraform {
  required_version = ">=0.11.8"
  
  backend "s3" {
    bucket = "" # the terraform state bucket has to be hand entered unfortunately
    key    = "tf_rds_rmq_ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

# this is for an aws specific provider(not gcp or azure)
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_db_instance" "airflow_rds" {

  identifier                  = "${var.db_identifier}"
  allocated_storage           = "150"
  storage_type                = "gp2"
  backup_retention_period     = "7"
  allow_major_version_upgrade = "false"
  auto_minor_version_upgrade  = "true"
  engine                      = "mysql"
  engine_version              = "5.7.21"
  instance_class              = "${var.db_instance_class}"
  username                    = "${var.db_master_username}"
  password                    = "${var.db_master_password}"
  port                        = "3306"
  publicly_accessible         = "false"
  vpc_security_group_ids      = ["${var.rds_vpc_security_group_ids}"]
  db_subnet_group_name        = "${var.db_subnet_greoup_name}"
  skip_final_snapshot         = true
  multi_az                    = true
  maintenance_window          = "Mon:07:00-Mon:07:30"
  backup_window               = "06:00-06:30"

  tags {
    Name            = "${var.db_identifier}"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# RabbitMQ Instance Related Items

data "template_file" "rabbitmq-user-data" {
  template = "${file("rabbitmq_install.tpl")}"
  vars {
    rabbitmq_admin_username = "${var.rabbitmq_admin_username}"
    rabbitmq_admin_password = "${var.rabbitmq_admin_password}"
    rabbitmq_airflow_username = "${var.rabbitmq_airflow_username}"
    rabbitmq_airflow_password = "${var.rabbitmq_airflow_password}"
  }
}

resource "aws_instance" "airflow_rabbitmq" {
  instance_type               = "${var.rabbitmq_instance_class}"
  ami                         = "${var.rabbitmq_ami}"
  associate_public_ip_address = false
  key_name                    = "${var.rabbitmq_keypair_name}"
  vpc_security_group_ids      = ["${var.rmq_vpc_security_group_ids}"]
  subnet_id                   = "${var.subnet_id1}"
  user_data                   = "${data.template_file.rabbitmq-user-data.rendered}"
  ebs_optimized               = "true"

  ebs_block_device {
    volume_size             = 25
    delete_on_termination   = true
    device_name             = "/dev/sdb"
  }

  tags {
    Name            = "airflow_rabbitmq110"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# S3 Log Bucket

resource "aws_s3_bucket" "s3_log_bucket" {
  bucket        = "${var.s3_log_bucket_name}"
  force_destroy = "true"

  tags {
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Airflow Instance Related Items

data "template_file" "airflow-user-data" {
  template = "${file("airflow_install.tpl")}"
  vars {
    rabbitmq_airflow_username = "${var.rabbitmq_airflow_username}"
    rabbitmq_airflow_password = "${var.rabbitmq_airflow_password}"
    rabbitmq_ip_address = "${aws_instance.airflow_rabbitmq.private_ip}"
    rds_url = "${aws_db_instance.airflow_rds.address}"
    db_airflow_username = "${var.db_airflow_username}"
    db_airflow_password = "${var.db_airflow_password}"
    db_master_username = "${var.db_master_username}"
    db_master_password = "${var.db_master_password}"
    airflow_dbname = "${var.airflow_dbname}"
    airflow_db_charset = "${var.airflow_db_charset}"
    airflow_username = "${var.airflow_username}"
    airflow_emailaddress = "${var.airflow_emailaddress}"
    airflow_password = "${var.airflow_password}"
    s3_log_bucket_name = "${var.s3_log_bucket_name}"
  }
}

resource "aws_launch_configuration" "lc_airflow" {
  depends_on                  = ["aws_instance.airflow_rabbitmq", "aws_db_instance.airflow_rds"]

  name                        = "lc_airflow110"
  image_id                    = "${var.airflow_ami}"
  instance_type               = "${var.airflow_instance_class}"
  key_name                    = "${var.airflow_keypair_name}"
  associate_public_ip_address = true
  security_groups             = ["${var.lc_vpc_security_group_ids}"]
  user_data                   = "${data.template_file.airflow-user-data.rendered}"
  iam_instance_profile        = "airflow_s3_instance_profile"
  ebs_optimized               = "true"

  ebs_block_device {
    volume_size             = 100
    delete_on_termination   = true
    device_name             = "/dev/sdb"    
  }
}

resource "aws_autoscaling_group" "asg_airflow" {
  depends_on                = ["aws_launch_configuration.lc_airflow"]

  name                      = "asg_airflow110"
  vpc_zone_identifier       = ["${var.subnet_id1}", "${var.subnet_id2}"]
  launch_configuration      = "${aws_launch_configuration.lc_airflow.id}"
  max_size                  = "2"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]

  tag {
    key                 = "Name"
    value               = "airflow_server110"
    propagate_at_launch = true
  }

  tag {
    key                 = "application"
    value               = "${var.tag_application}"
    propagate_at_launch = true
  }

  tag {
    key                 = "contact-email"
    value               = "${var.tag_contact_email}"
    propagate_at_launch = true
  }

  tag {
    key                 = "customer"
    value               = "${var.tag_customer}"
    propagate_at_launch = true
  }

  tag {
    key                 = "team"
    value               = "${var.tag_team}"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = "${var.tag_environment}"
    propagate_at_launch = true
  }
}
