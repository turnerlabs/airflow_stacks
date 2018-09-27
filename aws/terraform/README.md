# What is this

**tf_s3_state** - directory contains the terraform code to create an s3 bucket to store the terraform state for the terraform code in the tf_rds_rmq_ec2 directory.  

**tf_rds_ec2** - directory contains all the terraform code to create the stack with rabbatmq.

**tf_rds_rmq_ec2** - directory contains all the terraform code to create the complete stack for 1.10.

**tf_rds_rmq_ec2_110** - directory contains all the terraform code to create a second stack for 1.10. Assumes the  tf_rds_rmq_ec2 was already created.