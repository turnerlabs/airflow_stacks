# Airflow Worker Instance Related Items

data "template_file" "airflow-worker-user-data" {
  template = "${file("airflow_worker_install.tpl")}"
  vars {
    s3_airflow_bucket_name  = "${aws_s3_bucket.s3_airflow_bucket.id}"
    role_name               = "${aws_iam_role.airflow_instance.name}"
    db_region               = "${var.region}"
    airflow_secret          = "${aws_secretsmanager_secret.airflow_sm_secret.id}"
  }
}

resource "aws_launch_configuration" "lc_worker_airflow" {
  depends_on                  = ["aws_autoscaling_group.asg_websched_airflow", "aws_elasticache_cluster.airflow_elasticache", "aws_db_instance.airflow_rds", "aws_security_group.airflow_instance", "aws_iam_instance_profile.airflow_s3_instance_profile","aws_s3_bucket.s3_airflow_bucket"]

  name                        = "${var.prefix}_lc_worker_airflow"
  image_id                    = "${var.airflow_worker_ami}"
  instance_type               = "${var.airflow_worker_instance_class}"
  key_name                    = "${var.airflow_keypair_name}"
  security_groups             = ["${aws_security_group.airflow_instance.id}"]
  user_data                   = "${data.template_file.airflow-worker-user-data.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.airflow_s3_instance_profile.id}"
  
  root_block_device {
    volume_type                 = "gp2"
    volume_size                 = 80
    delete_on_termination       = true
  }
}

resource "aws_autoscaling_group" "asg_worker_airflow" {
  depends_on                = ["aws_launch_configuration.lc_worker_airflow"]

  name                      = "${var.prefix}_asg_worker_airflow"
  vpc_zone_identifier       = ["${var.private_subnet1_id}", "${var.private_subnet2_id}"]
  launch_configuration      = "${aws_launch_configuration.lc_worker_airflow.id}"
  max_size                  = "5"
  min_size                  = "1"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]

  tag {
    key                 = "Name"
    value               = "${var.prefix}_airflow_worker_server"
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

resource "aws_autoscaling_policy" "airflow_worker_scale_up_policy" {
  depends_on                = ["aws_autoscaling_group.asg_worker_airflow"]

  name                      = "${var.prefix}_airflow_worker_scale_up_policy"
  scaling_adjustment        = 1
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 120
  autoscaling_group_name    = "${aws_autoscaling_group.asg_worker_airflow.name}"
}

resource "aws_cloudwatch_metric_alarm" "airflow_worker_cw_add_alarm" {
  depends_on          = ["aws_autoscaling_policy.airflow_worker_scale_up_policy"]

  alarm_name          = "${var.prefix}_airflow_worker_cw_add_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg_worker_airflow.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.airflow_worker_scale_up_policy.arn}"]
}

resource "aws_autoscaling_policy" "airflow_worker_scale_down_policy" {
  depends_on                = ["aws_autoscaling_group.asg_worker_airflow"]

  name                      = "${var.prefix}_airflow_worker_scale_down_policy"
  scaling_adjustment        = -1
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 240
  autoscaling_group_name    = "${aws_autoscaling_group.asg_worker_airflow.name}"
}

resource "aws_cloudwatch_metric_alarm" "airflow_worker_cw_remove_alarm" {
  depends_on          = ["aws_autoscaling_policy.airflow_worker_scale_down_policy"]

  alarm_name          = "${var.prefix}_airflow_worker_cw_remove_alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg_worker_airflow.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.airflow_worker_scale_down_policy.arn}"]
}