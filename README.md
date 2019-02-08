# What is this

This was a repo is to put all the Airflow operationalized knowledge at Turner into one place but it got too big and I broke it out into the following pieces.

I've had to make a few decisions in my design(Python 3 and Airflow 1.10) as well as some of the resources I've used(MySQL and Redis) for each platform.  It's mainly to keep my sanity and make this managable.  Please feel free to fork this and use Postgres, Maria, RabbitMQ, etc.  It won't hurt my feelings.  :)

Before trying to run this please take a look at the documentation here:  http://airflow.incubator.apache.org/index.html

Here's our current stacks:

## AWS

### EC2

Terraform - https://github.com/turnerlabs/airflow_stack_aws_ec2_tf

Image - https://github.com/turnerlabs/airflow_stack_aws_ec2_ami
***

### Fargate

Terraform - https://github.com/turnerlabs/airflow_stack_aws_fg_tf

Docker Images - https://github.com/turnerlabs/airflow_stack_aws_fg_image
***

### GCP(work in progress with less work since Composer exists there)

Compute Enigne

Terraform - https://github.com/turnerlabs/airflow_stack_gcp_ce_tf

Image - https://github.com/turnerlabs/airflow_stack_gcp_ce_images
**

### Docker

Local Dockerized version for testing - https://github.com/turnerlabs/airflow_stack_docker
