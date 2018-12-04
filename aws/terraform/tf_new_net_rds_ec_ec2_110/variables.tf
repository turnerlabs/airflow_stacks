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

variable "availability_zone_1" {
  description = "az 1 of 2 azs"
  default     = "us-east-1c"
}

variable "availability_zone_2" {
  description = "az 2 of 2 azs"
  default     = "us-east-1d"
}
variable "airflow_websched_ami" {
  description = "Airflow Webserver / Scheduler AMI created by packer"
}

variable "airflow_websched_instance_class" {
  description = "Airflow websched instance size"
  default     = "t3.small"
}

variable "airflow_worker_ami" {
  description = "Airflow Worker AMI created by packer"
}

variable "airflow_worker_instance_class" {
  description = "Airflow worker instance size"
  default     = "t3.medium"
}

variable "airflow_keypair_name" {
  description = "AWS keypair to use on the airflow ec2 instance"
}

variable "db_identifier" {
  description = "Database identifier"
  default     = "airflow-rds"
}

variable "db_port" {
  description = "Database port"
  default     = "3306"
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

variable "db_airflow_dbname" {
  description = "MYSQL airflow database name"
  default     = "airflow"
}

variable "db_engine_version" {
  description = "MYSQL airflow engine version"
  default     = "8.0"
}

variable "db_instance_class" {
  description = "MYSQL airflow instance class"
  default     = "db.t2.small"
}

variable "db_parameter_group_name" {
  description = "MYSQL airflow parameter group"
  default     = "default.mysql8.0"
}

variable "db_charset" {
  description = "MYSQL airflow database character set"
  default     = "latin1"
}

variable "db_skip_final_snapshot"{
  description = "MYSQL airflow database character set"
  default     = "true"
}

variable "ec_node_type" {
  description = "Node type to use"
  default = "cache.t2.small"
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

variable "s3_airflow_log_bucket_name"  {
  description = "Airflow bucket for airflow logs"
}

variable "s3_airflow_access_log_bucket_name"  {
  description = "Airflow bucket for alb access logs"
}

variable "waf_ip"  {
  description = "instance ingress ip to allow"
}

variable "ingress_ips"  {
  description = "instance ingress ip to allow"
}

variable "ingress_ip_description"  {
  description = "instance ingress ip description"
}

variable "aws_account_number" {
  description = "AWS account number"  
}

variable "domain" {
  description = "Domain for Route53"  
}

variable "subdomain" {
  description = "Sub Domain for cert"
}

variable "alb_accesslog_account" {
  description="Look here for more info: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions"
  default="127311923021"
}

variable "secret_recovery_window_in_days" {
  description="How many days to keep a secret before deleting it.  0 is immediately"
  default="0"
}

variable "notification_email" {
  description="This email will receive sns notification from any resources that alarm.  It is required"
}