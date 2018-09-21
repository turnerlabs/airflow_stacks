#!/usr/bin/bash -x

set -e

sudo apt-get -y update
echo "------------------- apt update complete -------------------"

sudo apt-get -y install unattended-upgrades
echo "------------------- apt upgrade complete -------------------"

sudo apt-get -y install python-pip libmysqlclient-dev python-dev libkrb5-dev libsasl2-dev mysql-client-core-5.7
echo "------------------- aptitude python dependencies complete -------------------"

echo "export AIRFLOW_HOME=/home/ubuntu/airflow" >> /home/ubuntu/.bash_profile
echo "------------------- append AIRFLOW_HOME to bash profile complete -------------------"

export AIRFLOW_HOME=/home/ubuntu/airflow
export SLUGIFY_USES_TEXT_UNIDECODE=yes

sudo pip install --upgrade pip
echo "------------------- pip upgrade complete -------------------"

sudo pip install virtualenv
echo "------------------- pip install virtualenv complete -------------------"

virtualenv venv
echo "------------------- virtual environment creation complete -------------------"

source ~/venv/bin/activate
echo "------------------- activate virtual environment complete -------------------"

pip install "apache-airflow[all_dbs,celery,crypto,devel,gcp_api,jdbc,kerberos,mssql,mysql,password,postgres,qds,rabbitmq,redis,s3,samba,slack,snowflake,ssh]"
echo "------------------- install airflow complete -------------------"

airflow initdb
echo "------------------- initialize database phase 1 complete -------------------"

mkdir /home/ubuntu/airflow/dags
echo "------------------- create dag and plugins directory complete -------------------"

crontab -u ubuntu /home/ubuntu/crontab
echo "------------------- enable logs cleanup complete -------------------"

wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /home/ubuntu/cloud_sql_proxy
chmod +x /home/ubuntu/cloud_sql_proxy
sudo cp /home/ubuntu/cloud_sql_proxy /usr/local/bin/cloud_sql_proxy
echo "------------------- downloaded and copied cloud sql proxy -------------------"


sudo cp /home/ubuntu/airflow.sysconfig /etc/profile.d/airflow.sh
sudo cp /home/ubuntu/airflow.conf /usr/lib/tmpfiles.d

sudo cp /home/ubuntu/airflow-webserver.service /lib/systemd/system/airflow-webserver.service
sudo cp /home/ubuntu/airflow-scheduler.service /lib/systemd/system/airflow-scheduler.service
sudo cp /home/ubuntu/airflow-worker.service /lib/systemd/system/airflow-worker.service
sudo cp /home/ubuntu/cloud-sql-proxy.service /lib/systemd/system/cloud-sql-proxy.service

sudo mkdir /run/airflow
sudo chown ubuntu:ubuntu /run/airflow 
