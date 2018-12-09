#!/bin/bash -xe

export AIRFLOW_HOME=/home/ubuntu/airflow

echo "S3_AIRFLOW_BUCKET=${s3_airflow_bucket_name}" >> /etc/environment
echo "S3_AIRFLOW_BUCKET=${s3_airflow_bucket_name}" >> /etc/profile.d/airflow.sh

export S3_AIRFLOW_BUCKET=${s3_airflow_bucket_name}

secret=`/home/ubuntu/venv/bin/aws secretsmanager get-secret-value --region ${db_region} --secret-id ${airflow_secret}`
token=$(echo $secret | jq -r .SecretString)

echo "RDS_KEY=$token" >> /etc/environment
echo "RDS_KEY=$token" >> /etc/profile.d/airflow.sh

export RDS_KEY=$token

echo "############# Set initial environment variables for cron and systemd #############"

mkdir /home/ubuntu/airflow
chown ubuntu:ubuntu /home/ubuntu/airflow

echo "############# Created airflow directory #############"

mkdir /home/ubuntu/airflow/dags
chown ubuntu:ubuntu /home/ubuntu/airflow/dags
mkdir /home/ubuntu/airflow/data
chown ubuntu:ubuntu /home/ubuntu/airflow/data
mkdir /home/ubuntu/airflow/logs
chown ubuntu:ubuntu /home/ubuntu/airflow/logs
mkdir /home/ubuntu/airflow/plugins
chown ubuntu:ubuntu /home/ubuntu/airflow/plugins
mkdir /home/ubuntu/airflow/requirements
chown ubuntu:ubuntu /home/ubuntu/airflow/requirements
mkdir /home/ubuntu/airflow/variables
chown ubuntu:ubuntu /home/ubuntu/airflow/variables

echo "############# create common airflow directories complete #############"

/home/ubuntu/venv/bin/aws s3 cp s3://${s3_airflow_bucket_name}/ /home/ubuntu/airflow/ --recursive --quiet

if [ ! -e "/home/ubuntu/airflow/airflow.cfg" ]; then
    sleep 5m
    
    /home/ubuntu/venv/bin/aws s3 cp s3://${s3_airflow_bucket_name}/ /home/ubuntu/airflow/ --recursive --quiet
fi

echo "############# Copy important files from s3 locally #############"

chmod 600 /home/ubuntu/airflow/airflow.cfg
chmod 600 /home/ubuntu/airflow/unittests.cfg
chmod 600 /home/ubuntu/airflow/webserver_config.py
chmod 700 /home/ubuntu/airflow/connect.sh
chmod 700 /home/ubuntu/airflow/sm_update.sh

chown ubuntu:ubuntu /home/ubuntu/airflow/connect.sh
chown ubuntu:ubuntu /home/ubuntu/airflow/sm_update.sh
chown ubuntu:ubuntu /home/ubuntu/airflow/airflow.cfg
chown ubuntu:ubuntu /home/ubuntu/airflow/unittests.cfg
chown ubuntu:ubuntu /home/ubuntu/airflow/webserver_config.py

echo "############# Set correct permissions on files #############"

systemctl enable airflow-worker

systemctl daemon-reload

echo "############# Enabled airflow systemd #############"

systemctl start airflow-worker

echo "############# Started up airflow service #############"