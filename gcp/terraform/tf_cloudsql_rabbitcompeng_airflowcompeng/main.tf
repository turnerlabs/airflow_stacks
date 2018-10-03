# this section stores the terraform state for the gcs bucket in the terraform state bucket we created in step 1.
terraform {
    required_version = ">=0.11.8"
    
  backend "gcs" {
    bucket  = ""         # the terraform state bucket has to be hand entered unfortunately
    prefix  = "terraform/state"
  }
}

# this is for a gcp specific provider(not aws or azure)
provider "google" {
  credentials = "${file("${var.credentialspath}")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

# Instance for Airflow
resource "google_compute_instance" "airflow_instance" {
  description     = "This is used to create an airflow server instances."

  name                      = "airflow-instance"
  machine_type              = "${var.airflow_machine_type}"
  zone                      = "${var.zone}"
  can_ip_forward            = "${var.can_ip_forward}"
  tags                      = ["${var.airflow_tags}"]
  allow_stopping_for_update = "${var.allow_stopping_for_update}"

  // boot disk
  boot_disk {
    initialize_params {
      image = "${var.airflow_image}"
    }
  }

  // networking
  network_interface {
    subnetwork          = "${var.network_interface_subnetwork}"
    subnetwork_project  = "${var.network_interface_subnetwork_project}"
  }

  service_account {
    email   = "${var.service_account_email}"
    scopes  = ["${var.airflow_service_account_scope}"]
  }
}

# Instance for Rabbit
resource "google_compute_instance" "rabbitmq_instance" {
  description     = "This is used to create a rabbitmq server instances."

  name                      = "airflow-rabbitmq-instance"
  machine_type              = "${var.rmq_machine_type}"
  zone                      = "${var.zone}"
  can_ip_forward            = "${var.can_ip_forward}"
  tags                      = ["${var.rmq_tags}"]
  allow_stopping_for_update = "${var.allow_stopping_for_update}"

  // boot disk
  boot_disk {
    initialize_params {
      image = "${var.rmq_image}"
    }
  }

  // networking
  network_interface {
    subnetwork          = "${var.network_interface_subnetwork}"
    subnetwork_project  = "${var.network_interface_subnetwork_project}"
  }

  service_account {
    email   = "${var.service_account_email}"
    scopes  = ["${var.rmq_service_account_scope}"]
  }
}

#CloudSQL Instance
resource "google_sql_database_instance" "mysql_master" {
  name              = "airflow-mysql-master-instance"
  database_version  = "MYSQL_5_7"
  region            = "${var.region}"

  settings {
    tier = "${var.sql_tier}"
  }
}