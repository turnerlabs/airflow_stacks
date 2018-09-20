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
variable "s3_dag_bucket_name"  {
  description = "Airflow bucket for DAGs"
}
