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
  depends_on          = ["aws_security_group.airflow_lb","aws_s3_bucket.s3_airflow_access_log_bucket"]

  name                = "${var.prefix}-alb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = ["${aws_security_group.airflow_lb.id}"]
  subnets             = ["${aws_subnet.airflow_subnet_public_1c.id}", "${aws_subnet.airflow_subnet_public_1d.id}"]

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

resource "aws_lb_listener" "airflow_lb_listener" {
  depends_on        = ["aws_lb.airflow_lb","aws_acm_certificate_validation.cert","aws_lb_target_group.airflow_lb_tg"]

  load_balancer_arn = "${aws_lb.airflow_lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate_validation.cert.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.airflow_lb_tg.arn}"
  }
}
