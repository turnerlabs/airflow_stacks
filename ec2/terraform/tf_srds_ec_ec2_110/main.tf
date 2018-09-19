# this section stores the terraform state for the s3 bucket in the terraform state bucket we created in step 1.
terraform {
  backend "s3" {
    bucket = "tfstatesbairflow110" # the terraform state bucket has to be hand entered unfortunately
    key    = "tf_rds_rmq_ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

# this is for an aws specific provider(not gcp or azure)
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# Security Group Related Items

resource "aws_security_group" "airflow_rds" {
  name        = "airflow_rds"
  description = "Security group for access to rds server for airflow"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "airflow_rds"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_security_group" "airflow_ssh" {
  name        = "airflow_ssh"
  description = "Security group for access to airflow server"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["157.166.0.0/16"]
    description     = "Turner"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/8"]
    description     = "Turner"
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["157.166.0.0/16"]
    description     = "Turner"
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/8"]
    description     = "Turner"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "airflow_ssh"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_security_group" "airflow_ec" {
  name        = "airflow_ec"
  description = "Security group for access to ec server for airflow"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "airflow_ec"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}


# RDS Related Items

resource "aws_db_subnet_group" "airflow_rds_subnet_grp" {
  subnet_ids = ["${var.subnet_id1}", "${var.subnet_id2}"]

  tags {
    Name            = "airflow_rds"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_rds_cluster" "airflow_rds" {
  depends_on                      = ["aws_db_subnet_group.airflow_rds_subnet_grp", "aws_security_group.airflow_rds"]

  cluster_identifier              = "${var.db_identifier}-cluster"
  engine_mode                     = "serverless"
  master_username                 = "${var.db_master_username}"
  master_password                 = "${var.db_master_password}"
  vpc_security_group_ids          = ["${aws_security_group.airflow_rds.id}"]
  db_subnet_group_name            = "${aws_db_subnet_group.airflow_rds_subnet_grp.id}"
  skip_final_snapshot             = true
  preferred_backup_window         = "06:00-06:30"
  backup_retention_period         = 5
  db_cluster_parameter_group_name = "default.aurora5.6"
  
  scaling_configuration {
    auto_pause               = true
    max_capacity             = 256
    min_capacity             = 2
    seconds_until_auto_pause = 900
  }

  tags {
    Name            = "${var.db_identifier}"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Elasticache Related Items

resource "aws_elasticache_subnet_group" "airflow_ec_subnet_grp" {
  name       = "ec-airflow-subnet"
  subnet_ids = ["${var.subnet_id1}", "${var.subnet_id2}"]
}
resource "aws_elasticache_cluster" "airflow_elasticache" {
  cluster_id            = "airflow-cluster"
  engine                = "redis"
  node_type             = "cache.m3.medium"
  num_cache_nodes       = 1
  engine_version        = "4.0.10"
  parameter_group_name  = "default.redis4.0"
  port                  = 6379
  security_group_ids    = ["${aws_security_group.airflow_ec.id}"]
  subnet_group_name     = "${aws_elasticache_subnet_group.airflow_ec_subnet_grp.id}"
  
  tags {
    Name            = "airflow_node"
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

# IAM Role
resource "aws_iam_role" "airflow_s3_role" {
  depends_on  = ["aws_s3_bucket.s3_log_bucket"]

  name = "airflow_s3_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "airflow_s3_instance_profile" {
  depends_on  = ["aws_s3_bucket.s3_log_bucket", "aws_iam_role.airflow_s3_role", "aws_iam_role_policy.airflow_s3_policy", "aws_iam_role_policy.airflow_logs_policy"]
  
  name = "airflow_s3_instance_profile"
  role = "${aws_iam_role.airflow_s3_role.name}"
}

# IAM Role Policy
resource "aws_iam_role_policy" "airflow_s3_policy" {
  depends_on  = ["aws_s3_bucket.s3_log_bucket", "aws_iam_role.airflow_s3_role"]

  name = "airflow_s3_policy"
  role = "${aws_iam_role.airflow_s3_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}

# IAM Role Policy
resource "aws_iam_role_policy" "airflow_logs_policy" {
  depends_on  = ["aws_s3_bucket.s3_log_bucket", "aws_iam_role.airflow_s3_role"]

  name = "airflow_logs_policy"
  role = "${aws_iam_role.airflow_s3_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource": [
          "arn:aws:logs:*:*:*"
        ]
      }
   ]
}
EOF
}


# Airflow Instance Related Items

data "template_file" "airflow-user-data" {
  template = "${file("airflow_install.tpl")}"
  vars {
    ec_url = "${aws_elasticache_cluster.airflow_elasticache.cache_nodes.0.address}"
    rds_url = "${aws_rds_cluster.airflow_rds.endpoint}"
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
  depends_on                  = ["aws_elasticache_cluster.airflow_elasticache", "aws_rds_cluster.airflow_rds", "aws_security_group.airflow_ssh", "aws_iam_instance_profile.airflow_s3_instance_profile"]

  name                        = "lc_airflow"
  image_id                    = "${var.airflow_ami}"
  instance_type               = "${var.airflow_instance_class}"
  key_name                    = "${var.airflow_keypair_name}"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.airflow_ssh.id}"]
  user_data                   = "${data.template_file.airflow-user-data.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.airflow_s3_instance_profile.id}"
}

resource "aws_autoscaling_group" "asg_airflow" {
  depends_on                = ["aws_launch_configuration.lc_airflow"]

  name                      = "asg_airflow"
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
    value               = "airflow_server"
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