# Description

This is a terraform script to create a complete airflow stack including networking.

You will need to update the terraform state bucket in the main.tf file.  This should have already been created in the tf_s3_state directory.

It creates the following resources in AWS:

- 1 VPC
- 2 Private Subnets
- 2 Public Subnets
- Internet and NAT Gateways
- 1 ALB for Webserver
- 1 WAF
- 1 Subdomain created in Route53
- 1 SSL cert is created using ACM
- 1 Secret Manager key is created for access from Webserver / Scheduler instance to RDS instance.
- 1 MySQL RDS database
- 3 Security groups
  - 1 for RDS access
  - 1 for Elasticache access
  - 1 for AirFlow instance access
- 1 Launch Config using Airflow Webserver / Scheduler AMI
- 1 Auto Scale Group for Airflow Webserver / Scheduler
- 1 Launch Config using Airflow Worker AMI
- 1 Auto Scale Group for Airflow Worker

The Airflow instances will be able to communicate with Elasticache as well as Serverless Aurora.

Assumptions:

A Key Pair has already been created.
A domain has been registered in Route53 with a hosted zone.

Please check the variables.tf for a clear description of what each variable is that is passed to this terraform.

```bash
terraform init
```

```bash
terraform apply
-var 'tag_name=<>'
-var 'tag_application=<>'
-var 'tag_team=<>'
-var 'tag_environment=<>'
-var 'tag_contact_email=<>'
-var 'tag_customer=<>'
-var 'db_identifier=<>'
-var 'airflow_keypair_name=<>'
-var 'db_master_username=<>'
-var 'db_master_password=<>'
-var 'db_airflow_username=<>'
-var 'db_airflow_password=<>'
-var 'airflow_username=<>'
-var 'airflow_emailaddress=<>'
-var 'airflow_password=<>'
-var 'airflow_first=<>'
-var 'airflow_last=<>'
-var 'airflow_role=<>'
-var 's3_airflow_bucket_name=<>'
-var 's3_airflow_access_log_bucket_name=<>'
-var 's3_airflow_log_bucket_name=<>'
-var 'ingress_ips=<>'
-var 'ingress_ip_description=<>'
-var 'aws_account_number=<>'
-var 'airflow_worker_ami=<>'
-var 'airflow_websched_ami=<>'
-var 'prefix=<>'
-var 'domain=<>'
-var 'subdomain=<>'
```

All the variables that are defaulted

```bash
variable "tag_application" {}
variable "tag_contact_email" {}
variable "tag_customer" {}
variable "tag_team" {}
variable "tag_environment" {}

variable "prefix" {
  description = "Name to prefix all the resources with"
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
  description = "AWS keypair to use on the airflow ec2 instances.  They will need to be rotated."
}

variable "db_identifier" {
  description = "Database identifier"
  default     = "airflow_rds"
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

variable "db_airflow_password" {}

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

variable "ec_node_type" {
  description = "Elasticache Node type to use"
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
  description = "Default redis parameter group"
  default = "default.redis4.0"
}

variable "ec_port" {
  description = "Elasticache port"
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
  description = "S3 bucket for airflow configuration"
}

variable "s3_airflow_log_bucket_name"  {
  description = "S3 bucket for airflow logs"
}

variable "s3_airflow_access_log_bucket_name"  {
  description = "S3bucket for alb access logs"
}

variable "ingress_ips"  {
  description = "Instance ingress ips to allow. Used by ALB Security Group and WAF"
}

variable "ingress_ip_description"  {
  description = "Instance ingress ip description."
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
```
