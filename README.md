# What is this

This repo is an attempt to put all the Airflow operationalized knowledge at Turner into one place.  

I've had to make a few decisions in my design(Python 3 and Airflow 1.10) as well as some of the resources I've used(MySQL and Redis) for each platform.  It's mainly to keep my sanity and make this managable.  Please feel free to fork this and use Postgres, Maria, RabbitMQ, etc.  It won't hurt my feelings.  :)

Before trying to run this please take a look at the documentation here:  http://airflow.incubator.apache.org/index.html

Here's our current stacks:

**AWS(most work has been done here)**

![AWS](images/Airflow_10_26_18.jpg)

**GCP(work in progress with less work since Composer exists there)**

DIAGRAM TO COME

**Docker(work in progress)**

DIAGRAM TO COME

Please look over the issues and variable defintions before creating these stacks.  I default many of the settings for cost and to expedite creating and tearing down stacks so if you don't want your workers running on t2.micro's you would be advised to take a look at the variables.tf file in each terraform stack directory.

Please feel free to add any issues as well.  I want to make this a first class stack for each environment.
