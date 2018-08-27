#!/usr/bin/bash -x

set -e

sudo apt-get -y update
echo "------------------- apt update complete -------------------"

sudo apt-get -y install unattended-upgrades
echo "------------------- apt upgrade complete -------------------"

sudo apt-get -y install libkrb5-dev libsasl2-dev unixodbc-dev freetds-dev git python-pip python-dev build-essential mssql-tools
echo "------------------- airflow aptitude build dependencies complete -------------------"

sudo apt-get -y install software-properties-common locales libmysqlclient-dev libmysqld-dev mysql-client-core-5.7 unixodbc apt-transport-https ca-certificates curl openssl gnupg libxslt1-dev
echo "------------------- airflow aptitude airflow dependencies complete -------------------"

echo "export AIRFLOW_HOME=/home/ubuntu/airflow" >> /home/ubuntu/.bash_profile
echo "------------------- append AIRFLOW_HOME to bash profile complete -------------------"

export AIRFLOW_HOME=/home/ubuntu/airflow

pip install virtualenv
echo "------------------- pip install virtualenv complete -------------------"

virtualenv venv
echo "------------------- virtual environment creation complete -------------------"

source ~/venv/bin/activate
echo "------------------- activate virtual environment complete -------------------"

pip install --upgrade pip
echo "------------------- pip upgrade complete -------------------"

pip install html5lib boto3 markupsafe flask_bcrypt snowflake-connector-python celery
echo "------------------- install python packages that are needed complete -------------------"

pip install "apache-airflow[all]"
echo "------------------- install airflow complete -------------------"

airflow initdb
echo "------------------- initialize database phase 1 complete -------------------"

mkdir /home/ubuntu/airflow/dags
echo "------------------- create dag and plugins directory complete -------------------"

crontab -u ubuntu /home/ubuntu/crontab
echo "------------------- enable logs cleanup complete -------------------"

sudo cp /home/ubuntu/airflow.sysconfig /etc/profile.d/airflow.sh
sudo cp /home/ubuntu/airflow.conf //usr/lib/tmpfiles.d

sudo cp /home/ubuntu/airflow-webserver.service /lib/systemd/system/airflow-webserver.service
sudo cp /home/ubuntu/airflow-scheduler.service /lib/systemd/system/airflow-scheduler.service
sudo cp /home/ubuntu/airflow-worker.service /lib/systemd/system/airflow-worker.service

sudo mkdir /run/airflow
sudo chown ubuntu:ubuntu /run/airflow 
