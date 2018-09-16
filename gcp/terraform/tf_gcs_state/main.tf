provider "google" {
  credentials = "${file("${var.credentialspath}")}"
  project     = "${var.project}"
  region      = "${var.region}"
}
# create a google storage bucket
resource "google_storage_bucket" "bucket" {
  name        = "${var.bucket_name}"

  versioning {
    enabled = "${var.versioning}"
  }

  labels {
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}
