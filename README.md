# What is this

Before trying to run this please take a look at the documentation here:  http://airflow.incubator.apache.org/index.html

This repo is an attempt to put all the Airflow operationalized knowledge into one place.  Currently there are several AMI's that need to be created via Packer initially(one for Rabbit MQ and one for Airflow(either Python 2.7 or Python 3.6)) before you can create the Airflow stack via Terraform.  

We are currently using a RDS MySQL backend(AWS), Cloud SQL(GCP), and MySQL(container) to store the airflow data and RabbitMQ to store messages via Celery.  

Most of the work has been done on the ec2 version.  The docker version was mainly done to allow me to test locally but it's functional.  The gcp version is a work in progress(most of the issues are around terraform).

Please feel free to add any issues to github.

**gcp** -  directory has an Airflow Terraform / Packer stack based around Airflow, Rabbitmq, CloudSQL. 

**ec2** -  directory has an Airflow Terraform / Packer stack based around Airflow, Rabbitmq, RDS.

**docker** - directory contains an Airflow stack using Airflow, Rabbitmq, MySQL.  This also needs some work but it's pretty close.

### Articles on Airflow

<http://michal.karzynski.pl/blog/2017/03/19/developing-workflows-with-apache-airflow/>