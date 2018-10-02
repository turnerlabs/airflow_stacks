# Description

This is a terraform script to create a complete airflow stack.

You will need to update the terraform / backend / bucket in the main.tf in tf_rds_ec_ec2 to use this terraform state bucket.

It creates the following resources in AWS:

- 1 MySQL ServerlessRDS database
- 3 Security groups
  - 1 for RDS access
  - 1 for Elasticache access
  - 1 for AirFlow access
- 1 Launch Config using Airflow AMI
- 1 Auto Scale Group

The Airflow server will be able to communicate with RabbitMQ server as well as the RDS server.

Assumptions:

A VPC with subnets with private access(but with internet outbound accessible) has already been created.
A Key Pair has already been created.

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