# Description

## This is a Work in Progress

This is a terraform script to create a complete airflow stack.

You will need to update the terraform / backend / bucket in the main.tf to use the terraform state bucket created in tf_gcs_state

It creates the following resources in GCP:

- 1 MySQL CloudSQL database
- 1 Instance Template for Airflow Image
- 1 Instance Group for Airflow
- 1 Instance Template for RabbitMQ Image
- 1 Instance Group for RabbitMQ

The Airflow server will be able to communicate with the Cloud SQL server.

Assumptions:

Airflow and RabbitMQ Google Cloud Images have already been created using Packer scripts.

If using against resources on premise:
A VPC that has been given access to a Shared VPC with Cloud Interconnect Access.

If using against cloud resources:
A VPC that already has a NAT gateway created to allow for easier creation of firewaal rules on external resources.

A ssh Key Pair has already been created.

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
-var 'vpc_id=<>'
-var 'subnet_id1=<>'
-var 'subnet_id2=<>'
-var 'db_instance_class=<>'
-var 'db_identifier=<>'
-var 'db_master_username=<>'
-var 'db_master_password=<>'
-var 'db_airflow_username=<>'
-var 'db_airflow_password=<>'
-var 'airflow_ami=<>'
-var 'airflow_instance_class=<>'
-var 'airflow_keypair_name=<>'
-var 'airflow_username=<>'
-var 'airflow_emailaddress=<>'
-var 'airflow_password=<>'
-var 's3_log_bucket_name=<>'
```
