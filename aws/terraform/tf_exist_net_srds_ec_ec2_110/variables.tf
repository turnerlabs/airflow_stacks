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

variable "prefix" {
  description = "Name to prefix all the items with"
}

variable "vpc_id" {
  description = "VPC to launch into"
}

variable "private_subnet_id1" {
  description = "Private subnet to launch rds, elasticcache, and instances in.  Should be in a different AZ than private_subnet_id2"
}

variable "private_subnet_id2" {
  description = "Private subnet to launch rds, elasticcache, and instances in.  Should be in a different AZ than private_subnet_id1"
}

variable "public_subnet_id1" {
  description = "Public subnet to launch alb in.  Should be in a different AZ than public_subnet_id2"
}

variable "public_subnet_id2" {
  description = "Public subnet to launch alb in.  Should be in a different AZ than public_subnet_id1"
}

variable "db_identifier" {
  description = "Database identifier"
  default     = "airflow_rds"
}

variable "airflow_websched_ami" {
  description = "Airflow Webserver / Scheduler AMI created by packer"
}

variable "airflow_websched_instance_class" {
  description = "Airflow websched instance size"
  default     = "t3.medium"
}

variable "airflow_worker_ami" {
  description = "Airflow Worker AMI created by packer"
}

variable "airflow_worker_instance_class" {
  description = "Airflow worker instance size"
  default     = "c4.large"
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

variable "db_airflow_dbname" {
  description = "MYSQL airflow database name"
  default     = "airflow"
}

variable "db_cluster_parameter_group_name" {
  description = "MYSQL airflow parameter group"
  default     = "default.aurora5.6"
}

variable "db_charset" {
  description = "MYSQL airflow database character set"
  default     = "latin1"
}

variable "db_max_capacity" {
  description = "Max capacity to allow aurora to have"
  default = 256
}

variable "db_min_capacity" {
  description = "Min capacity to allow aurora to have"
  default = 2
}

variable "db_seconds_until_auto_pause" {
  description = "Time without any activity before pausing.  Default is 15 minutews"
  default = 900
}

variable "ec_node_type" {
  description = "Node type to use"
  default = "cache.m3.medium"
}

variable "ec_engine_version" {
  description = "Redis version to use"
  default = "4.0.10"
}

variable "ec_num_cache_nodes" {
  description = "Number of cache nodes"
  default = 1
}

variable "ec_parameter_group_name" {
  description = "defualt redis parameter group"
  default = "default.redis4.0"
}

variable "ec_port" {
  description = "elasticache port"
  default = 6379
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

variable "airflow_first"  {
  description = "Airflow users first name for website access"
}

variable "airflow_last"  {
  description = "Airflow users last name for website access"
}

variable "airflow_role"  {
  description = "Airflow users role for website access. Roles can be Admin, User, Op, Viewer, and Public"
}

variable "s3_airflow_bucket_name"  {
  description = "Airflow bucket for airflow shared directory"
}

variable "s3_airflow_access_log_bucket_name"  {
  description = "Airflow bucket for alb access logs"
}

variable "ingress_ip"  {
  description = "instance ingress ip to allow"
}

variable "ingress_ip_description"  {
  description = "instance ingress ip description"
}

variable "aws_account_number" {
  description = "AWS account number"  
}