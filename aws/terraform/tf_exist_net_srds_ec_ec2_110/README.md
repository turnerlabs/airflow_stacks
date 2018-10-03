# Description

This is a terraform script to create a complete airflow stack NOT including networking.

You will need to update the terraform state bucket in the main.tf file.  This should have already been created in the tf_s3_state directory.

It creates the following resources in AWS:

- 1 ALB for Webserver
- 1 MySQL ServerlessRDS database
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

Networking is setup as such.....

- 1 VPC
- 2 Private Subnets
- 2 Public Subnets
- Internet and NAT Gateways

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
-var 'ingress_ip=<>'
-var 'ingress_ip_description=<>'
-var 'aws_account_number=<>'
-var 'airflow_worker_ami=<>'
-var 'airflow_worker_instance_class=<>'
-var 'airflow_websched_ami=<>'
-var 'airflow_websched_instance_class=<>'
-var 'prefix=<>'
-var 'vpc_id=<>'
-var 'private_subnet_id1=<>'
-var 'private_subnet_id2=<>'
-var 'public_subnet_id1=<>'
-var 'public_subnet_id2=<>'
-var 'domain=<>'
-var 'subdomain=<>'
```
