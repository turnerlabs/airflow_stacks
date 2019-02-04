resource "aws_ecs_cluster" "airflow_ecs_cluster" {
  name = "${var.prefix}_ecs_cluster"
}

resource "aws_ecs_task_definition" "airflow_webserver_ecs_task_def" {
  family                    = "${var.prefix}_webserver"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "1024"
  memory                    = "2048"
  execution_role_arn        = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  task_role_arn             = "${aws_iam_role.iam_role.arn}"

  tags {
    Name            = "${var.prefix}_webserver"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.prefix}_webserver",
    "image": "${var.airflow_webserver_image}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "command": [
        "webserver"
    ],
    "entryPoint": [
        "/entrypoint.sh"
    ],
    "workingDirectory": "/usr/local/airflow",
    "environment": [
       {
        "name": "AIRFLOW_HOME",
        "value" : "/usr/local/airflow"
       },
       {
        "name": "AIRFLOW_CONFIG",
        "value" : "/usr/local/airflow/airflow.cfg"
       },
       {
        "name": "FORWARDED_ALLOW_IPS",
        "value" : "*"
       },
       {
        "name": "EC_URL",
        "value" : "${aws_elasticache_cluster.airflow_elasticache.cache_nodes.0.address}"
       },
       {
        "name": "EC_PORT",
        "value" : "${var.ec_port}"
       },
       {
        "name": "RDS_URL",
        "value" : "${aws_db_instance.airflow_rds.address}"
       },
       {
        "name": "RDS_PORT",
        "value" : "${var.db_port}"
       },
       {
        "name": "DB_REGION",
        "value" : "${var.region}"
       },
       {
        "name": "DB_AIRFLOW_USERNAME",
        "value" : "${var.db_airflow_username}"
       },
       {
        "name": "DB_AIRFLOW_PASSWORD",
        "value" : "${random_string.airflow_rds_password.result}"
       },
       {
        "name": "DB_MASTER_USERNAME",
        "value" : "${var.db_master_username}"
       },
       {
        "name": "DB_MASTER_PASSWORD",
        "value" : "${var.db_master_password}"
       },
       {
        "name": "DB_AIRFLOW_DBNAME",
        "value" : "${var.db_airflow_dbname}"
       },
       {
        "name": "DB_CHARSET",
        "value" : "${var.db_charset}"
       },
       {
        "name": "AIRFLOW_SECRET",
        "value" : "${aws_secretsmanager_secret.airflow_sm_secret.id}"
       },
       {
        "name": "S3_AIRFLOW_BUCKET_NAME",
        "value" : "${aws_s3_bucket.s3_airflow_bucket.id}"
       },
       {
        "name": "S3_AIRFLOW_LOG_BUCKET_NAME",
        "value" : "${aws_s3_bucket.s3_airflow_log_bucket.id}"
       },
       {
        "name": "AIRFLOW_USERNAME",
        "value" : "${var.airflow_username}"
       },
       {
        "name": "AIRFLOW_EMAILADDRESS",
        "value" : "${var.airflow_emailaddress}"
       },
       {
        "name": "AIRFLOW_PASSWORD",
        "value" : "${var.airflow_password}"
       },
       {
        "name": "AIRFLOW_FIRST",
        "value" : "${var.airflow_first}"
       },
       {
        "name": "AIRFLOW_LAST",
        "value" : "${var.airflow_last}"
       },
       {
        "name": "AIRFLOW_ROLE",
        "value" : "${var.airflow_role}"
       },
       {
        "name": "SUBDOMAIN",
        "value" : "${var.subdomain}"
       }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.prefix}_webserver_ecs_service",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "airflow_scheduler_ecs_task_def" {
  family                    = "${var.prefix}_scheduler"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "1024"
  memory                    = "2048"
  execution_role_arn        = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  task_role_arn             = "${aws_iam_role.iam_role.arn}"

  tags {
    Name            = "${var.prefix}_scheduler"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.prefix}_scheduler",
    "image": "${var.airflow_scheduler_image}",
    "essential": true,
    "command": [
        "scheduler"
    ],
    "entryPoint": [
        "/entrypoint.sh"
    ],
    "workingDirectory": "/usr/local/airflow",
    "environment": [
       {
        "name": "AIRFLOW_HOME",
        "value" : "/usr/local/airflow"
       },
       {
        "name": "AIRFLOW_CONFIG",
        "value" : "/usr/local/airflow/airflow.cfg"
       },
       {
        "name": "DB_REGION",
        "value" : "${var.region}"
       },
       {
        "name": "AIRFLOW_SECRET",
        "value" : "${aws_secretsmanager_secret.airflow_sm_secret.id}"
       },
       {
        "name": "S3_AIRFLOW_BUCKET_NAME",
        "value" : "${aws_s3_bucket.s3_airflow_bucket.id}"
       },
       {
        "name": "SUBDOMAIN",
        "value" : "${var.subdomain}"
       }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.prefix}_scheduler_ecs_service",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "airflow_worker_ecs_task_def" {
  family                    = "${var.prefix}_worker"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "2048"
  memory                    = "4096"
  execution_role_arn        = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  task_role_arn             = "${aws_iam_role.iam_role.arn}"

  tags {
    Name            = "${var.prefix}_worker"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.prefix}_worker",
    "image": "${var.airflow_worker_image}",
    "essential": true,
    "command": [
        "worker"
    ],
    "entryPoint": [
        "/entrypoint.sh"
    ],
    "workingDirectory": "/usr/local/airflow",
    "environment": [
       {
        "name": "AIRFLOW_HOME",
        "value" : "/usr/local/airflow"
       },
       {
        "name": "AIRFLOW_CONFIG",
        "value" : "/usr/local/airflow/airflow.cfg"
       },
       {
        "name": "DB_REGION",
        "value" : "${var.region}"
       },
       {
        "name": "AIRFLOW_SECRET",
        "value" : "${aws_secretsmanager_secret.airflow_sm_secret.id}"
       },
       {
        "name": "S3_AIRFLOW_BUCKET_NAME",
        "value" : "${aws_s3_bucket.s3_airflow_bucket.id}"
       },
       {
        "name": "SUBDOMAIN",
        "value" : "${var.subdomain}"
       }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.prefix}_worker_ecs_service",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}


resource "aws_ecs_service" "airflow_webserver_ecs_svc" {
  name                    = "${var.prefix}_webserver_ecs_service"
  depends_on              = [ "aws_lb_listener.airflow_lb_listener", "aws_iam_role.iam_role", "aws_iam_role_policy.airflow_s3", "aws_iam_role_policy.airflow_logs", "aws_iam_role_policy.airflow_secrets" ]
  cluster                 = "${aws_ecs_cluster.airflow_ecs_cluster.id}"
  launch_type             = "FARGATE"
  task_definition         = "${aws_ecs_task_definition.airflow_webserver_ecs_task_def.arn}"
  desired_count           = "1"
  enable_ecs_managed_tags = true
  propagate_tags          = "TASK_DEFINITION"

  network_configuration {
    security_groups = ["${aws_security_group.airflow_instance.id}"]
    subnets         = ["${aws_subnet.airflow_subnet_private_1c.id}", "${aws_subnet.airflow_subnet_private_1d.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.airflow_lb_tg.id}"
    container_name   = "${var.prefix}_webserver"
    container_port   = "8080"
  }
}

resource "aws_ecs_service" "airflow_scheduler_ecs_svc" {
  name                    = "${var.prefix}_scheduler_ecs_service"
  depends_on              = [ "aws_iam_role.iam_role", "aws_iam_role_policy.airflow_s3", "aws_iam_role_policy.airflow_logs", "aws_iam_role_policy.airflow_secrets" ]
  cluster                 = "${aws_ecs_cluster.airflow_ecs_cluster.id}"
  launch_type             = "FARGATE"
  task_definition         = "${aws_ecs_task_definition.airflow_scheduler_ecs_task_def.arn}"
  desired_count           = "1"
  enable_ecs_managed_tags = true
  propagate_tags          = "TASK_DEFINITION"

  network_configuration {
    security_groups = ["${aws_security_group.airflow_instance.id}"]
    subnets         = ["${aws_subnet.airflow_subnet_private_1c.id}", "${aws_subnet.airflow_subnet_private_1d.id}"]
  }
}

resource "aws_ecs_service" "airflow_worker_ecs_svc" {
  name                    = "${var.prefix}_worker_ecs_service"
  depends_on              = [ "aws_iam_role.iam_role", "aws_iam_role_policy.airflow_s3", "aws_iam_role_policy.airflow_logs", "aws_iam_role_policy.airflow_secrets" ]
  cluster                 = "${aws_ecs_cluster.airflow_ecs_cluster.id}"
  launch_type             = "FARGATE"
  task_definition         = "${aws_ecs_task_definition.airflow_worker_ecs_task_def.arn}"
  desired_count           = "1"
  enable_ecs_managed_tags = true
  propagate_tags          = "TASK_DEFINITION"

  network_configuration {
    security_groups = ["${aws_security_group.airflow_instance.id}"]
    subnets         = ["${aws_subnet.airflow_subnet_private_1c.id}", "${aws_subnet.airflow_subnet_private_1d.id}"]
  }
}


resource "aws_cloudwatch_log_group" "webserver_logs" {
  name              = "/fargate/service/${var.prefix}_webserver_ecs_service"
  retention_in_days = "14"
  tags {
    Name            = "${var.prefix}_webserver"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_cloudwatch_log_group" "scheduler_logs" {
  name              = "/fargate/service/${var.prefix}_scheduler_ecs_service"
  retention_in_days = "14"
  tags {
    Name            = "${var.prefix}_scheduler"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_cloudwatch_log_group" "worker_logs" {
  name              = "/fargate/service/${var.prefix}_worker_ecs_service"
  retention_in_days = "14"
  tags {
    Name            = "${var.prefix}_worker"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}