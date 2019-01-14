# Description

This is a packer builder and custom provisioner to create an AMI for an airflow webserver and scheduler.

## Builder

The builder phase uses a t2 medium of the Ubuntu 16.04 AMI in the east region as the instance type to run the provisioner on.  The instance size can be changed to something larger if you need to create the AMI faster.  This is just for building the AMI and has no bearing on the long running instance.  That is determined in the terraform script.

## Provisioner

The provisioner phase installs all the airflow server components.  If you take a look at the provision.sh script you can see all that's happening.


## Process

Once the provisioner has completed, an AMI will be created using the ami_name in the ubuntu.json file.

## Airflow SubPackages that are installed:
Default ones(from http://airflow.readthedocs.io/en/latest/installation.html)
all

Custom ones:

*** Please note that this airflow AMI is created with the following features in mind although all these subpackages are installed:
- Celery as the worker task executor
- Elasticache is the queue used for Celery
- RDS MySQL is the database used for the airflow metadata
- Airflow logs are rotated out every night using logrotate since they get very large quickly
- Chrony to keep time up to date
- Airflow services using systemd

Here's the command line needed to build the AMI.

```bash
packer build
-var 'tag_application=<>'
-var 'tag_contact_email=<>'
-var 'tag_customer=<>'
-var 'tag_team=<>'
-var 'tag_environment=<>'
-var 'vpcid_to_build_in=<>'
-var 'subnetid_to_build_in=<>'
ubuntu.json
```
