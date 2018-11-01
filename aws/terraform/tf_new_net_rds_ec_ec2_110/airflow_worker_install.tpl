#!/bin/bash -xe

mkdir /home/ubuntu/airflow
chown ubuntu:ubuntu /home/ubuntu/airflow

echo "############# Created airflow directory #############"

id=`id -u ubuntu`
group=`id -g ubuntu`

/usr/bin/s3fs ${s3_airflow_bucket_name} -o use_cache=/tmp,rw,noatime,iam_role="${role_name}",uid=$id,gid=$group,allow_other /home/ubuntu/airflow

echo "############# Enabled s3 mount for airflow directory #############"

sleep 3m

echo "############# Slept 5 minutes to wait for airflow.cfg to be created correctly #############"

systemctl enable airflow-worker

systemctl daemon-reload

echo "############# Enabled airflow systemd #############"

systemctl start airflow-worker

echo "############# Started up airflow service #############"