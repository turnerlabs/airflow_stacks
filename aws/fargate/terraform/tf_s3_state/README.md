# Description

This is a terraform script to create the s3 terraform state bucket.

You will need to update the terraform / backend / bucket in the main.tf in tf_new_net_rds_ec_ec2_110 to use this terraform state bucket.

```bash
terraform init
```

```bash
terraform apply
```