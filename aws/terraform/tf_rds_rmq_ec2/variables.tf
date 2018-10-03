variable "region" {
  description = "Region"
  default     = "us-east-1"
}

variable "profile" {
  description = "Profile from credentials"
  default     = "default"
}

variable "tag_application" {}
variable "tag_contact_email" {}
variable "tag_customer" {}
variable "tag_team" {}
variable "tag_environment" {}

variable "vpc_id" {
  description = "VPC to launch into"
}

variable "subnet_id1" {
  description = "Subnet to launch RDS into. Hopefully in different AZ"
}

variable "subnet_id2" {
  description = "Subnet to launch RDS into. Hopefully in different AZ"
}

variable "db_instance_class" {
  description = "Database instance size"
  default     = "db.t2.medium"
}

variable "db_identifier" {
  description = "Database identifier"
  default     = "airflow_rds"
}

variable "airflow_ami" {
  description = "Airflow AMI created by packer"
}

variable "airflow_instance_class" {
  description = "Airflow instance size"
  default     = "t2.large"
}

variable "airflow_keypair_name" {
  description = "AWS keypair to use on the airflow ec2 instance"
}

variable "rabbitmq_ami" {
  description = "RabbitMQ AMI created by packer"
}

variable "rabbitmq_instance_class" {
  description = "RabbitMQ instance size"
  default     = "t2.medium"
}

variable "rabbitmq_keypair_name" {
  description = "AWS keypair to use on the rabbit ec2 instance"
}

variable "rabbitmq_admin_username" {
  description = "RabbitMQ Admin username"
  default     = "admin"
}
variable "rabbitmq_admin_password" {}

variable "rabbitmq_airflow_username" {
  description = "RabbitMQ Airflow username"
  default     = "airflow"
}
variable "rabbitmq_airflow_password" {}

variable "db_master_username" {
  description = "MySQL master username"
  default     = "admin"
}

variable "db_master_password" {}

variable "db_airflow_username" {
  description = "MySQL Airflow username"
  default     = "airflow"
}

variable "db_airflow_password" {}

variable "airflow_dbname"{
  description = "MYSQL airflow database name"
  default     = "airflow"
}

variable "airflow_db_charset"{
  description = "MYSQL airflow database character set"
  default     = "latin1"
}

variable "airflow_username" {
  description = "Airflow username for website access"
  default     = "airflow"
}

variable "airflow_emailaddress" {
  description = "Airflow emailaddress for website access"
}

variable "airflow_password"  {
  description = "Airflow password for website access"
}

variable "s3_log_bucket_name"  {
  description = "Airflow bucket to eventually log to"
}
