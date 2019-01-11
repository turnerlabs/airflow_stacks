resource "aws_ecs_cluster" "airflow_ecs_cluster" {
  name = "${var.prefix}_ecs_cluster"
}

resource "aws_ecs_task_definition" "airflow_websched_ecs_task_def" {
  family                    = "${var.prefix}_websched"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = "10"
  memory                    = "1024"
  task_role_arn             = "${aws_iam_role.airflow_task}"

  tags {
    Name            = "${var.prefix}_websched"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }

  container_definitions = <<DEFINITION
[
  {
    "cpu": 10,
    "image": "${var.app_image}",
    "memory": 1024,
    "name": "${var.prefix}_websched",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "airflow_websched_ecs_svc" {
  name            = "${var.prefix}_ecs_service"
  depends_on = [ "aws_alb_listener.airflow_lb_listener" ]

  cluster         = "${aws_ecs_cluster.airflow_ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.airflow_websched_ecs_task_def.arn}"
  desired_count   = "1"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.airflow_instance.id}"]
    subnets         = ["${aws_subnet.airflow_subnet_private_1c.id}", "${aws_subnet.airflow_subnet_private_1d.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.airflow_lb_tg.id}"
    container_name   = "${var.prefix}_websched"
    container_port   = "8080"
  }
}