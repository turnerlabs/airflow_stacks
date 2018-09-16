# Description

This is a terraform script to create the gcs terraform state bucket.

You will need to update the terraform / backend / bucket in the main.tf in tf_cloudsql_rabbitcompeng_airflowcompeng to use this terraform state bucket.

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
-var 'region=<>'
-var 'project=<>'
-var 'bucket_name=<>'
-var 'versioning=<>'
-var 'credentialspath=<>'
```