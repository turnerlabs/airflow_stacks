# Description

This is a packer builder and custom provisioner to create an AMI for rabbitmq

## Builder

The builder phase uses a t2 medium of the Ubuntu 16.04 AMI in the east region as the instance type to run the provisioner on.  The instance size can be changed to something larger if you need to create the AMI faster.  This is just for building the AMI and has no bearing on the long running instance.  That is determined in the terraform script.

## Provisioner

The provisioner phase installs all the rabbit mq server components.  If you take a look at the provision.sh script you can see all that's happening.

## Process

Once the provisioner has completed, an image will be created using the ami_name in the ubuntu.json file.

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
