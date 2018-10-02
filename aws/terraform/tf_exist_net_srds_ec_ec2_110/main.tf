# this section stores the terraform state for the s3 bucket in the terraform state bucket we created in step 1.
terraform {
  required_version = ">=0.11.8"

  backend "s3" {
    bucket = "tfstatesbairflow110" # the terraform state bucket has to be hand entered unfortunately
    key    = "tf_srds_ec_ec2_110/terraform.tfstate"
    region = "us-east-1"
  }
}

# this is for an aws specific provider(not gcp or azure)
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# Load Balancer Security Group
resource "aws_security_group" "airflow_lb" {
  name        = "airflow_lb"
  description = "Security group for access to airflow load balancer"
  vpc_id      = "${var.vpc_id}"
  
  # This needs to be expanded to all the ip ranges.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["${var.ingress_ip}"]
    description     = "${var.ingress_ip_description}"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "airflow_lb"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Instance Security Group
resource "aws_security_group" "airflow_instance" {
  name        = "airflow_instance"
  description = "Security group for access to airflow server"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.airflow_lb.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "airflow_instance"
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

  name        = "airflow_rds"
  description = "Security group for access to rds server for airflow"
  vpc_id      = "${var.vpc_id}"

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
    Name            = "airflow_rds"
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

  name        = "airflow_ec"
  description = "Security group for access to ec server for airflow"
  vpc_id      = "${var.vpc_id}"

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
    Name            = "airflow_ec"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# S3 Airflow Bucket
resource "aws_s3_bucket" "s3_airflow_bucket" {
  bucket        = "${var.s3_airflow_bucket_name}"
  force_destroy = "true"

  tags {
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# S3 ALB access log Bucket
# resource "aws_s3_bucket" "s3_airflow_access_log_bucket" {
#   bucket        = "${var.s3_airflow_access_log_bucket_name}"
#   force_destroy = "true"
#   tags {
#     application     = "${var.tag_application}"
#     contact-email   = "${var.tag_contact_email}"
#     customer        = "${var.tag_customer}"
#     team            = "${var.tag_team}"
#     environment     = "${var.tag_environment}"
#   }

# policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::${var.aws_account_number}:root"
#       },
#       "Action": "s3:PutObject",
#       "Resource": "arn:aws:s3:::${var.s3_airflow_access_log_bucket_name}/*"
#     }
#   ]
# }
# EOF
# }

# IAM Role
resource "aws_iam_role" "airflow_s3_role" {

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

# IAM Instance Profile
resource "aws_iam_instance_profile" "airflow_s3_instance_profile" {
  depends_on  = ["aws_iam_role.airflow_s3_role", "aws_iam_role_policy.airflow_s3_policy", "aws_iam_role_policy.airflow_logs_policy"]
  
  name = "airflow_s3_instance_profile"
  role = "${aws_iam_role.airflow_s3_role.name}"
}

# IAM S3 Role Policy
# need to tighten the heck out of the below policy
resource "aws_iam_role_policy" "airflow_s3_policy" {
  depends_on  = ["aws_iam_role.airflow_s3_role"]

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

# IAM Logs Role Policy
resource "aws_iam_role_policy" "airflow_logs_policy" {
  depends_on  = ["aws_iam_role.airflow_s3_role"]

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

# Application Load Balancer

resource "aws_lb_target_group" "airflow_lb_tg" {
  name     = "airflow-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  
  health_check {
    port      = 8080
    protocol  = "HTTP"
    path      = "/login"
  }

  tags {
    Name            = "airflow_lb_tg"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_lb" "airflow_lb" {
  # depends_on         = ["aws_security_group.airflow_lb","aws_s3_bucket.s3_airflow_access_log_bucket"]

  name               = "airflow-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.airflow_lb.id}"]
  subnets            = ["${var.public_subnet_id1}", "${var.public_subnet_id2}"]

  # access_logs {
  #   bucket  = "${aws_s3_bucket.s3_airflow_access_log_bucket.id}"
  #   prefix  = "airflow-lb"
  #   enabled = true
  # }

  tags {
    Name            = "airflow_alb"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_lb_listener" "airflow_lb_listener" {
  load_balancer_arn = "${aws_lb.airflow_lb.arn}"
  port              = "80"
  protocol          = "HTTP"
#  port              = "443"
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2015-05"
#  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.airflow_lb_tg.arn}"
  }
}


# RDS Related Items
resource "aws_db_subnet_group" "airflow_rds_subnet_grp" {
  subnet_ids = ["${var.private_subnet_id1}", "${var.private_subnet_id2}"]

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
  db_cluster_parameter_group_name = "${var.db_cluster_parameter_group_name}"
  
  scaling_configuration {
    auto_pause               = true
    max_capacity             = "${var.db_max_capacity}"
    min_capacity             = "${var.db_min_capacity}"
    seconds_until_auto_pause = "${var.db_seconds_until_auto_pause}"
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
  subnet_ids = ["${var.private_subnet_id1}", "${var.private_subnet_id2}"]
}

resource "aws_elasticache_cluster" "airflow_elasticache" {
  cluster_id            = "airflow-cluster"
  engine                = "redis"
  node_type             = "${var.ec_node_type}"
  num_cache_nodes       = "${var.ec_num_cache_nodes}"
  engine_version        = "${var.ec_engine_version}"
  parameter_group_name  = "${var.ec_parameter_group_name}"
  port                  = "${var.ec_port}"
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
    db_airflow_dbname = "${var.db_airflow_dbname}"
    db_charset = "${var.db_charset}"
    s3_airflow_bucket_name = "${var.s3_airflow_bucket_name}"
    role_name = "${aws_iam_role.airflow_s3_role.name}"
    airflow_username = "${var.airflow_username}"
    airflow_emailaddress = "${var.airflow_emailaddress}"
    airflow_password = "${var.airflow_password}"
    airflow_first = "${var.airflow_first}"
    airflow_last = "${var.airflow_last}"
    airflow_role = "${var.airflow_role}"
  }
}

resource "aws_launch_configuration" "lc_airflow" {
  depends_on                  = ["aws_elasticache_cluster.airflow_elasticache", "aws_rds_cluster.airflow_rds", "aws_security_group.airflow_instance", "aws_iam_instance_profile.airflow_s3_instance_profile","aws_s3_bucket.s3_airflow_bucket"]

  name                        = "lc_airflow"
  image_id                    = "${var.airflow_ami}"
  instance_type               = "${var.airflow_instance_class}"
  key_name                    = "${var.airflow_keypair_name}"
  security_groups             = ["${aws_security_group.airflow_instance.id}"]
  user_data                   = "${data.template_file.airflow-user-data.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.airflow_s3_instance_profile.id}"
}

resource "aws_autoscaling_group" "asg_airflow" {
  depends_on                = ["aws_launch_configuration.lc_airflow", "aws_lb_target_group.airflow_lb_tg"]

  name                      = "asg_airflow"
  vpc_zone_identifier       = ["${var.private_subnet_id1}", "${var.private_subnet_id2}"]
  launch_configuration      = "${aws_launch_configuration.lc_airflow.id}"
  max_size                  = "2"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]
  target_group_arns         = ["${aws_lb_target_group.airflow_lb_tg.arn}"]

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