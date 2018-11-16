# AWS SNS Email

resource "aws_sns_topic" "airflow_sns_notifications" {
  name = "airflow_sns_notifications"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.airflow_sns_notifications.arn} --protocol email --notification-endpoint ${var.notification_email}"
  }
}

# Airflow Cloudwatch Resource Monitors

# RDS MySQL(CPU, Free Storage, and Disk Queue) - connections vary by db type so that's not a good alarm.

resource "aws_cloudwatch_metric_alarm" "airflow_rds_cpu_utilization_too_high" {
  depends_on          = ["aws_db_instance.airflow_rds"]

  alarm_name          = "${var.prefix}_airflow_rds_cpu_utilization_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Average RDS CPU utilization has been over 80% for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]

  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.airflow_rds.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "airflow_rds_free_storage_space_too_low" {
  depends_on          = ["aws_db_instance.airflow_rds"]

  alarm_name          = "${var.prefix}_airflow_rds_free_storage_space_threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "2000000000"
  alarm_description   = "Average RDS free storage space has been less than 2 gigabyte for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]

  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.airflow_rds.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "airflow_rds_disk_queue_depth_too_high" {
  depends_on          = ["aws_db_instance.airflow_rds"]

  alarm_name          = "${var.prefix}_airflow_rds_disk_queue_depth_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "64"
  alarm_description   = "Average RDS disk queue depth has been over 64 for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]

  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.airflow_rds.id}"
  }
}

# Elasticache(CPU and Memory)

resource "aws_cloudwatch_metric_alarm" "airflow_elasticache_cpu_utilization_too_high" {
  depends_on          = ["aws_elasticache_cluster.airflow_elasticache"]

  alarm_name          = "${var.prefix}_airflow_ec_cpu_utilization_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Average Elasticache CPU Utilization has been over 80% for the last 5 minutes."
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  
  dimensions {
    CacheClusterId = "${aws_elasticache_cluster.airflow_elasticache.cluster_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "airflow_elasticache_memory_too_low" {
  depends_on          = ["aws_elasticache_cluster.airflow_elasticache"]

  alarm_name          = "${var.prefix}_airflow_ec_memory_too_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "180"
  statistic           = "Average"
  threshold           = "1000000000"
  alarm_description   = "Average Elasticache Freeable Memory has been less than 1 gigabyte for the last 3 minutes."
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  
  dimensions {
    CacheClusterId = "${aws_elasticache_cluster.airflow_elasticache.cluster_id}"
  }
}

# ASG on Webserver / Scheduler(CPUUtilization)

resource "aws_cloudwatch_metric_alarm" "airflow_asg_websched_cpu_utilization_too_high" {
  depends_on          = ["aws_autoscaling_group.asg_websched_airflow"]

  alarm_name          = "${var.prefix}_airflow_asg_websched_cpu_utilization_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Average WebSched Autoscale Group CPU Utilization has been over 80% for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg_websched_airflow.id}"
  }
}

# ASG on Worker(CPUUtilization)

resource "aws_cloudwatch_metric_alarm" "airflow_asg_woker_cpu_utilization_too_high" {
  depends_on          = ["aws_autoscaling_group.asg_worker_airflow"]

  alarm_name          = "${var.prefix}_airflow_asg_worker_cpu_utilization_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Average Worker Autoscale Group CPU Utilization has been over 80% for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg_worker_airflow.id}"
  }
}

# NAT Gateway(Traffic)

resource "aws_cloudwatch_metric_alarm" "airflow_natg_dropping_packets" {
  depends_on          = ["aws_nat_gateway.airflow_natgw"]

  alarm_name          = "${var.prefix}_airflow_natg_dropping_packets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "PacketsDropCount"
  namespace           = "AWS/NATGateway"
  period              = "600"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Sum NAT Gateway Packets Dropped Count has been over 0 bytes for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  
  dimensions {
    NatGatewayId = "${aws_nat_gateway.airflow_natgw.id}"
  }
}

# WAF(Blocked Requests)

resource "aws_cloudwatch_metric_alarm" "airflow_waf_blocked_requests" {
  depends_on    = ["aws_wafregional_web_acl.airflow_waf_web_acl"]

  alarm_name          = "${var.prefix}_airflow_waf_blocked_requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "WAF"
  period              = "600"
  statistic           = "Sum"
  threshold           = "1000"
  alarm_description   = "Sum WAF Blocked Request Count has been over 1000 for the last 10 minutes"
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  alarm_actions       = ["${aws_sns_topic.airflow_sns_notifications.arn}"]
  
  dimensions {
    WebACL  = "${aws_wafregional_web_acl.airflow_waf_web_acl.id}"
    Region  = "${var.region}"
    Rule    = "${aws_wafregional_rule.airflow_waf_rule.id}"
  }
}