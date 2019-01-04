# How to on AWS

## How to create this stack?

Step 1. Build the Packer AMI's

[Build Webserver Scheduler AMI](https://github.com/turnerlabs/airflow_stacks/tree/master/aws/packer/airflow_websched_python3)

[Build Worker AMI](https://github.com/turnerlabs/airflow_stacks/tree/master/aws/packer/airflow_worker_python3)

Step 2. Run the Terraform scripts

[Create the state bucket to contain the Airflow stacks state](https://github.com/turnerlabs/airflow_stacks/tree/master/aws/terraform/tf_s3_state/README.md)

[Create the Airflow stack](https://github.com/turnerlabs/airflow_stacks/tree/master/aws/terraform/tf_new_net_rds_ec_ec2_110/README.md)

## How to use Airflow once it's stood up

1. Login to Airflow website.

## How do I get my DAGs into Airflow

1. Make changes to your dag in the dags folder and commit the change to the appropriate github repo.

2. Push your changes to github.

3. Circle Ci will deploy the dags to airflow.

4. Scheduler will check for changes every 5 minutes so keep an eye on the UI on the website for updates.

## What if I have a specific python module I need in my code

1. Make changes to the requirements.txt file in the requirements directory and commit the chnage to the appropriate github repo.

- If the requirements.txt file does NOT exist in the repo, create a requirements directory and then create a new text file named requirements.txt locally and add your module in the format "FooProject >= 1.2" to the top of the file.

2. Push your changes to github.

3. Circle Ci will deploy the requirements.txt file to airflow once itspushed to master.

4. A Cron job on all nodes will pick up requirements.txt file and install the modules.

## How long do my task logs stay out in S3?

- 0-30 days - In standard storage

- 30-60 days - Moved to standard ia

- 60-180 days - Moved to glacier

- 180 days - Removed from bucket
