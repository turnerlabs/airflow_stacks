# How to on AWS

## How to create this stack?

Step 1. Build the Packer AMI's

[Build Webserver Scheduler AMI](/packer/airflow_websched_python3/README.md)

[Build Worker AMI](/packer/airflow_worker_python3/README.md)

Step 2. Run the Terraform scripts

[Create the state bucket to contain the Airflow stacks state](/terraform/tf_s3_state/README.md)

[Create the Airflow stack](/terraform/tf_new_net_rds_ec_ec2_110/README.md)

## How to use Airflow once it's stood up

1. Login to Airflow website.

## How do I get my DAGs into Airflow

*** DAG's will eventually be put in github and ci cd will be used to move files to the DAG s3 bucket ***

1. Check the dags folder in the airflow S3 bucket to see if a file with your name exists already.

- If a file does exist, please rename your file and upload the file to the dags folder in the airflow S3 bucket.

- If a file does NOT exist, upload the file to the dags folder in the airflow S3 bucket.

## What if I have a specific python module I need in my code

*** requirements.txt file will eventually be put in github and ci cd will be used to move the requirements.txt file to the s3 bucket ***

1. Check the root of the airflow S3 bucket to see if a requirements.txt file exists already.

- If the requirements.txt file does exist, please download the file and add your module in the format "FooProject >= 1.2" to the bottom of the requirements.txt file.  Once complete, upload the updated requirments.txt file to the root of the airflow S3 bucket.

- If the requirements.txt file does NOT exist in the airflow S3 bucket, create a new text file named requirements.txt locally and add your module in the format "FooProject >= 1.2" to the top of the file.  Once complete, upload the new requirements.txt file to the root of the airflow S3 bucket.

2. Cron job on worker nodes will pick up requirements.txt file and install modules in file.

## How long do my task logs stay out in S3?

- 0-30 days - In standard storage

- 30-60 days - Moved to standard ia

- 60-180 days - Moved to glacier

- 180 days - Removed from bucket