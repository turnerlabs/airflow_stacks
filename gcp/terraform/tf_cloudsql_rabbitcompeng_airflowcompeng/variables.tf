variable "region" {
  description = "Region"
  default     = "us-east1"
}

variable "project" {
  description = "GCP Project ID"
  default     = "default"
}
variable "credentialspath" {}

variable "airflow_machine_type" {
  description = "machine type to run airflow on"
  default     = "n1-standard-1"
}

variable "airflow_tags" {
  description = "tags"
}

variable "airflow_image"{
  description = "airflow image created using packer"
} 

variable "airflow_service_account_scope"{
  description = ""
  default     = "sql-admin"
} 

variable "rmq_machine_type" {
  description = "machine type to run airflow on"
  default     = "n1-standard-1"
}

variable "rmq_tags" {
  description = "tags"
}

variable "rmq_image"{
  description = "airflow image created using packer"
} 

variable "rmq_service_account_scope"{
  description = ""
  default     = ""
} 

variable "zone" {
  description = "Region"
  default     = "us-east1-b"
}

variable "can_ip_forward" {
  description = "can forward traffic"
  default     = "true"
}

variable "allow_stopping_for_update"{
  description = "can instance be stopped to apply updates"
  default     = "true"
} 

variable "network_interface_subnetwork"{
  description = ""
} 

variable "network_interface_subnetwork_project"{
  description = "can instance be stopped to apply updates"
} 

variable "service_account_email"{
  description = "service account to run as"
} 

variable "sql_tier" {
  description = "service account to run as"
  default     = "db-g1-small"
}