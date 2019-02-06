# Airflow Webserver / Scheduler Instance Related Items
# Using an lc / asg to keep webserver and scheduler up and running but only 1 instance should ever be running.
data "template_file" "airflow-websched-user-data" {
  template = "${file("airflow_websched_install.tpl")}"
  vars {
    ec_url = "${aws_elasticache_cluster.airflow_elasticache.cache_nodes.0.address}"
    rds_url = "${aws_db_instance.airflow_rds.address}"
    db_region = "${var.region}"
    db_airflow_username = "${var.db_airflow_username}"
    db_airflow_password = "${random_string.airflow_rds_password.result}"
    db_master_username = "${var.db_master_username}"
    db_master_password = "${var.db_master_password}"
    db_airflow_dbname = "${var.db_airflow_dbname}"
    db_resource_id = "${aws_db_instance.airflow_rds.resource_id}"
    db_charset = "${var.db_charset}"
    db_port = "${var.db_port}"
    airflow_secret = "${aws_secretsmanager_secret.airflow_sm_secret.id}"
    s3_airflow_bucket_name = "${aws_s3_bucket.s3_airflow_bucket.id}"
    s3_airflow_log_bucket_name = "${aws_s3_bucket.s3_airflow_log_bucket.id}"
    role_name = "${aws_iam_role.airflow_instance.name}"
    airflow_username = "${var.airflow_username}"
    airflow_emailaddress = "${var.airflow_emailaddress}"
    airflow_password = "${var.airflow_password}"
    airflow_first = "${var.airflow_first}"
    airflow_last = "${var.airflow_last}"
    airflow_role = "${var.airflow_role}"
    subdomain = "${var.subdomain}"
  }
}

resource "aws_launch_configuration" "lc_websched_airflow" {
  depends_on                  = ["aws_elasticache_cluster.airflow_elasticache", "aws_db_instance.airflow_rds", "aws_security_group.airflow_instance", "aws_iam_instance_profile.airflow_s3_instance_profile","aws_s3_bucket.s3_airflow_bucket"]

  name                        = "${var.prefix}_lc_websched_airflow"
  image_id                    = "${var.airflow_websched_ami}"
  instance_type               = "${var.airflow_websched_instance_class}"
  key_name                    = "${var.airflow_keypair_name}"
  security_groups             = ["${aws_security_group.airflow_instance.id}"]
  user_data                   = "${data.template_file.airflow-websched-user-data.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.airflow_s3_instance_profile.id}"
  
  root_block_device {
    volume_type                 = "gp2"
    volume_size                 = 80
    delete_on_termination       = true
  }
}

resource "aws_autoscaling_group" "asg_websched_airflow" {
  depends_on                = ["aws_launch_configuration.lc_websched_airflow", "aws_lb_target_group.airflow_lb_tg"]

  name                      = "${var.prefix}_asg_websched_airflow"
  vpc_zone_identifier       = ["${var.private_subnet1_id}", "${var.private_subnet2_id}"]  
  launch_configuration      = "${aws_launch_configuration.lc_websched_airflow.id}"
  max_size                  = "1"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]
  target_group_arns         = ["${aws_lb_target_group.airflow_lb_tg.arn}"]

  tag {
    key                 = "Name"
    value               = "${var.prefix}_airflow_websched_server"
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
