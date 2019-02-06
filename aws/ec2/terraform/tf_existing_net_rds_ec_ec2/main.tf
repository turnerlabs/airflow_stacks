# this section stores the terraform state for the s3 bucket in the terraform state bucket we created in step 1.
terraform {
  required_version = ">=0.11.8"
  
  backend "s3" {
    bucket = "" # the terraform state bucket has to be hand entered unfortunately
    key    = "tf_existing_net_rds_ec_ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

# this is for an aws specific provider(not gcp or azure)
provider "aws" {
  version = "~> 1.43"
  region  = "${var.region}"
  profile = "${var.profile}"
}