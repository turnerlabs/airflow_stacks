# this section stores the terraform state for the s3 bucket in the terraform state bucket we created in step 1.
terraform {
  required_version = ">=0.11.8"
  
  backend "s3" {
    bucket = "" # the terraform state bucket has to be hand entered unfortunately
    key    = "tf_new_net_srds_ec_ec2_110/terraform.tfstate"
    region = "us-east-1"
  }
}

# this is for an aws specific provider(not gcp or azure)
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# VPC 

resource "aws_vpc" "airflow_vpc" {
  cidr_block            = "10.0.0.0/16"
  instance_tenancy      = "default"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  enable_classiclink    = false

  tags {
    Name            = "${var.prefix}_vpc"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Private Subnets

resource "aws_subnet" "airflow_subnet_private_1c" {
  depends_on                      = ["aws_vpc.airflow_vpc"]
  vpc_id                          = "${aws_vpc.airflow_vpc.id}"
  cidr_block                      = "10.0.1.0/24"
  availability_zone               = "us-east-1c"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false

  tags {
    Name            = "${var.prefix}_subnet_private_1c"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_subnet" "airflow_subnet_private_1d" {
  depends_on                      = ["aws_vpc.airflow_vpc"]
  vpc_id                          = "${aws_vpc.airflow_vpc.id}"
  cidr_block                      = "10.0.2.0/24"
  availability_zone               = "us-east-1d"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false

  tags {
    Name            = "${var.prefix}_subnet_private_1d"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Public Subnets

resource "aws_subnet" "airflow_subnet_public_1c" {
  depends_on                      = ["aws_vpc.airflow_vpc"]
  vpc_id                          = "${aws_vpc.airflow_vpc.id}"
  cidr_block                      = "10.0.3.0/24"
  availability_zone               = "us-east-1c"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = false

tags {
    Name            = "${var.prefix}_subnet_public_1c"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_subnet" "airflow_subnet_public_1d" {
  depends_on                      = ["aws_vpc.airflow_vpc"]
  vpc_id                          = "${aws_vpc.airflow_vpc.id}"
  cidr_block                      = "10.0.4.0/24"
  availability_zone               = "us-east-1d"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = false

  tags {
    Name            = "${var.prefix}_subnet_public_1d"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "airflow_igw" {
  depends_on  = ["aws_vpc.airflow_vpc"]
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  tags {
    Name            = "${var.prefix}_igw"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# NAT Gateway

resource "aws_eip" "airflow_nat_eip" {
  vpc         = true
  depends_on  = ["aws_internet_gateway.airflow_igw"]
}

resource "aws_nat_gateway" "airflow_natgw" {
  depends_on    = ["aws_vpc.airflow_vpc", "aws_internet_gateway.airflow_igw", "aws_subnet.airflow_subnet_public_1c"]
  allocation_id = "${aws_eip.airflow_nat_eip.id}"
  subnet_id     = "${aws_subnet.airflow_subnet_public_1c.id}"

  tags {
      Name            = "${var.prefix}_natgw"
      application     = "${var.tag_application}"
      contact-email   = "${var.tag_contact_email}"
      customer        = "${var.tag_customer}"
      team            = "${var.tag_team}"
      environment     = "${var.tag_environment}"
  }
}

# Main Route Table

resource "aws_route_table" "airflow_rt_main" {
  depends_on  = ["aws_vpc.airflow_vpc"]
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  tags {
    Name            = "${var.prefix}_rt_main"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_1c" {
  depends_on      = ["aws_subnet.airflow_subnet_private_1c"]
  subnet_id       = "${aws_subnet.airflow_subnet_private_1c.id}"
  route_table_id  = "${aws_route_table.airflow_rt_main.id}"
}

resource "aws_route_table_association" "aws_route_table_association_private_1d" {
  depends_on      = ["aws_subnet.airflow_subnet_private_1d"]
  subnet_id       = "${aws_subnet.airflow_subnet_private_1d.id}"
  route_table_id  = "${aws_route_table.airflow_rt_main.id}"
}

resource "aws_route" "route_ngw" { 
  depends_on              = ["aws_nat_gateway.airflow_natgw"]  
  route_table_id          = "${aws_route_table.airflow_rt_main.id}"
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = "${aws_nat_gateway.airflow_natgw.id}"
}

# Custom Route Table

resource "aws_route_table" "airflow_rt_custom" {
  depends_on  = ["aws_vpc.airflow_vpc"]
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  tags {
    Name            = "${var.prefix}_rt_custom"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_route_table_association" "aws_route_table_association_public_1c" {
  depends_on      = ["aws_subnet.airflow_subnet_public_1c"]
  subnet_id       = "${aws_subnet.airflow_subnet_public_1c.id}"
  route_table_id  = "${aws_route_table.airflow_rt_custom.id}"
}

resource "aws_route_table_association" "aws_route_table_association_public_1d" {
  depends_on      = ["aws_subnet.airflow_subnet_public_1d"]
  subnet_id       = "${aws_subnet.airflow_subnet_public_1d.id}"
  route_table_id  = "${aws_route_table.airflow_rt_custom.id}"
}

resource "aws_route" "route_igw" { 
  depends_on              = ["aws_internet_gateway.airflow_igw"]  
  route_table_id          = "${aws_route_table.airflow_rt_custom.id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.airflow_igw.id}"
}

# Load Balancer Security Group

resource "aws_security_group" "airflow_lb" {
  name        = "${var.prefix}_lb"
  description = "Security group for access to airflow load balancer"
  vpc_id      = "${aws_vpc.airflow_vpc.id}"
  
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

# S3 Airflow Bucket
resource "aws_s3_bucket" "s3_airflow_bucket" {
  bucket        = "${var.prefix}${var.s3_airflow_bucket_name}"
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
resource "aws_s3_bucket" "s3_airflow_access_log_bucket" {
  bucket        = "${var.s3_airflow_access_log_bucket_name}"
  force_destroy = "true"
  tags {
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }

policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.s3_airflow_access_log_bucket_name}/*",
      "Principal": {
        "AWS": [
          "127311923021"
        ]
      }
    }
  ]
}
EOF
}

# IAM Role
resource "aws_iam_role" "airflow_s3_role" {

  name = "${var.prefix}_s3_role"
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
  
  name = "${var.prefix}_s3_instance_profile"
  role = "${aws_iam_role.airflow_s3_role.name}"
}

# IAM S3 Role Policy
# need to tighten the heck out of the below policy
resource "aws_iam_role_policy" "airflow_s3_policy" {
  depends_on  = ["aws_iam_role.airflow_s3_role"]

  name = "${var.prefix}_s3_policy"
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

  name = "${var.prefix}_logs_policy"
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
  name     = "${var.prefix}-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.airflow_vpc.id}"
  
  health_check {
    port      = 8080
    protocol  = "HTTP"
    path      = "/login/"
  }

  tags {
    Name            = "${var.prefix}_lb_tg"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_lb" "airflow_lb" {
  # depends_on         = ["aws_security_group.airflow_lb","aws_s3_bucket.s3_airflow_access_log_bucket"]

  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.airflow_lb.id}"]
  subnets            = ["${aws_subnet.airflow_subnet_public_1c.id}", "${aws_subnet.airflow_subnet_public_1d.id}"]

  access_logs {
    bucket  = "${aws_s3_bucket.s3_airflow_access_log_bucket.id}"
    prefix  = "airflow-lb"
    enabled = true
  }

  tags {
    Name            = "${var.prefix}_alb"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Certs and Route53 stuff

data "aws_route53_zone" "airflow_r53_zone" {
  name = "${var.domain}"
}

resource "aws_route53_record" "airflow_r53_record" {
  zone_id = "${data.aws_route53_zone.airflow_r53_zone.zone_id}"
  type    = "CNAME"
  name    = "${var.subdomain}"
  records = ["${aws_lb.airflow_lb.dns_name}"]
  ttl     = "30"
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
  subnet_ids = ["${aws_subnet.airflow_subnet_private_1c.id}", "${aws_subnet.airflow_subnet_private_1d.id}"]

  tags {
    Name            = "${var.prefix}_rds"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}
resource "aws_rds_cluster" "airflow_rds" {
  depends_on                      = ["aws_db_subnet_group.airflow_rds_subnet_grp", "aws_security_group.airflow_rds"]

  cluster_identifier              = "${var.prefix}-${var.db_identifier}-cluster"
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
    Name            = "${var.prefix}-${var.db_identifier}"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}


# Elasticache Related Items
resource "aws_elasticache_subnet_group" "airflow_ec_subnet_grp" {
  name       = "${var.prefix}-ec-subnet"
  subnet_ids = ["${aws_subnet.airflow_subnet_private_1c.id}", "${aws_subnet.airflow_subnet_private_1d.id}"]
}

resource "aws_elasticache_cluster" "airflow_elasticache" {
  cluster_id            = "${var.prefix}-cluster"
  engine                = "redis"
  node_type             = "${var.ec_node_type}"
  num_cache_nodes       = "${var.ec_num_cache_nodes}"
  engine_version        = "${var.ec_engine_version}"
  parameter_group_name  = "${var.ec_parameter_group_name}"
  port                  = "${var.ec_port}"
  security_group_ids    = ["${aws_security_group.airflow_ec.id}"]
  subnet_group_name     = "${aws_elasticache_subnet_group.airflow_ec_subnet_grp.id}"
  
  tags {
    Name            = "${var.prefix}_cluster"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}


# Airflow Weserver / Scheduler Instance Related Items
# Using an lc / asg to keep webserver and scheduler up and running but only 1 instance should ever be running.
data "template_file" "airflow-websched-user-data" {
  template = "${file("airflow_websched_install.tpl")}"
  vars {
    ec_url = "${aws_elasticache_cluster.airflow_elasticache.cache_nodes.0.address}"
    rds_url = "${aws_rds_cluster.airflow_rds.endpoint}"
    db_airflow_username = "${var.db_airflow_username}"
    db_airflow_password = "${var.db_airflow_password}"
    db_master_username = "${var.db_master_username}"
    db_master_password = "${var.db_master_password}"
    db_airflow_dbname = "${var.db_airflow_dbname}"
    db_charset = "${var.db_charset}"
    s3_airflow_bucket_name = "${aws_s3_bucket.s3_airflow_bucket.id}"
    role_name = "${aws_iam_role.airflow_s3_role.name}"
    airflow_username = "${var.airflow_username}"
    airflow_emailaddress = "${var.airflow_emailaddress}"
    airflow_password = "${var.airflow_password}"
    airflow_first = "${var.airflow_first}"
    airflow_last = "${var.airflow_last}"
    airflow_role = "${var.airflow_role}"
  }
}

resource "aws_launch_configuration" "lc_websched_airflow" {
  depends_on                  = ["aws_elasticache_cluster.airflow_elasticache", "aws_rds_cluster.airflow_rds", "aws_security_group.airflow_instance", "aws_iam_instance_profile.airflow_s3_instance_profile","aws_s3_bucket.s3_airflow_bucket"]

  name                        = "${var.prefix}_lc_websched_airflow"
  image_id                    = "${var.airflow_websched_ami}"
  instance_type               = "${var.airflow_websched_instance_class}"
  key_name                    = "${var.airflow_keypair_name}"
  security_groups             = ["${aws_security_group.airflow_instance.id}"]
  user_data                   = "${data.template_file.airflow-websched-user-data.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.airflow_s3_instance_profile.id}"
}

resource "aws_autoscaling_group" "asg_websched_airflow" {
  depends_on                = ["aws_launch_configuration.lc_websched_airflow", "aws_lb_target_group.airflow_lb_tg"]

  name                      = "${var.prefix}_asg_websched_airflow"
  vpc_zone_identifier       =  ["${aws_subnet.airflow_subnet_private_1c.id}", "${aws_subnet.airflow_subnet_private_1d.id}"]
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

# Airflow Worker Instance Related Items
data "template_file" "airflow-worker-user-data" {
  template = "${file("airflow_worker_install.tpl")}"
  vars {
    s3_airflow_bucket_name = "${aws_s3_bucket.s3_airflow_bucket.id}"
    role_name = "${aws_iam_role.airflow_s3_role.name}"
  }
}

resource "aws_launch_configuration" "lc_worker_airflow" {
  depends_on                  = ["aws_autoscaling_group.asg_websched_airflow", "aws_elasticache_cluster.airflow_elasticache", "aws_rds_cluster.airflow_rds", "aws_security_group.airflow_instance", "aws_iam_instance_profile.airflow_s3_instance_profile","aws_s3_bucket.s3_airflow_bucket"]

  name                        = "${var.prefix}_lc_worker_airflow"
  image_id                    = "${var.airflow_worker_ami}"
  instance_type               = "${var.airflow_worker_instance_class}"
  key_name                    = "${var.airflow_keypair_name}"
  security_groups             = ["${aws_security_group.airflow_instance.id}"]
  user_data                   = "${data.template_file.airflow-worker-user-data.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.airflow_s3_instance_profile.id}"
}

resource "aws_autoscaling_group" "asg_worker_airflow" {
  depends_on                = ["aws_launch_configuration.lc_worker_airflow"]

  name                      = "${var.prefix}_asg_worker_airflow"
  vpc_zone_identifier       =  ["${aws_subnet.airflow_subnet_private_1c.id}", "${aws_subnet.airflow_subnet_private_1d.id}"]
  launch_configuration      = "${aws_launch_configuration.lc_worker_airflow.id}"
  max_size                  = "5"
  min_size                  = "1"
  desired_capacity          = "1"
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