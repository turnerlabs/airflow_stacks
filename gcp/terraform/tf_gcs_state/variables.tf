variable "region" {
  description = "Region"
  default     = "us-east1"
}

variable "project" {
  description = "GCP Project ID"
  default     = "default"
}

variable "tag_application" {}
variable "tag_contact_email" {}
variable "tag_customer" {}
variable "tag_team" {}
variable "tag_environment" {}

variable "bucket_name" {}

variable "credentialspath" {}

variable "versioning" {
  default = false
}
