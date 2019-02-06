provider "random" {
  version = "~> 2.0.0"
}

# Random password and Secrets Manager

resource "random_string" "airflow_rds_password" {
  length  = 30
  special = false
}

resource "aws_secretsmanager_secret" "airflow_sm_secret" {
  name                    = "${var.prefix}_airflow_user_pass"
  recovery_window_in_days = 0 # make this configurable
}

resource "aws_secretsmanager_secret_version" "airflow_sm_secret_version" {
  secret_id     = "${aws_secretsmanager_secret.airflow_sm_secret.id}"
  secret_string = "${random_string.airflow_rds_password.result}"
}
