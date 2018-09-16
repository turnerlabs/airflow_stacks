#!/usr/bin/bash -x

set -e

sudo apt-get -y update
echo "------------------- apt update complete -------------------"

sudo apt-get -y install unattended-upgrades
echo "------------------- apt upgrade complete -------------------"

sudo apt-get -y install python-pip libmysqlclient-dev python-dev libkrb5-dev libsasl2-dev mysql-client-core-5.7 s3fs
echo "------------------- airflow aptitude dependencies complete -------------------"

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

pip install "apache-airflow[all]"
echo "------------------- install airflow complete -------------------"

airflow initdb
echo "------------------- initialize database phase 1 complete -------------------"

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
echo "------------------- download aws logs -------------------"

sudo python ./awslogs-agent-setup.py -n -r us-east-1 -c /home/ubuntu/awslogs.conf
echo "------------------- install aws logs -------------------"

mkdir /home/ubuntu/airflow/dags
echo "------------------- create dag and plugins directory complete -------------------"

sudo service awslogs start
echo "------------------- start of awslogs complete -------------------"

sudo systemctl enable awslogs
echo "------------------- enable autostart of awslogs complete -------------------"

crontab -u ubuntu /home/ubuntu/crontab
echo "------------------- enable logs cleanup complete -------------------"

sudo cp /home/ubuntu/airflow.sysconfig /etc/profile.d/airflow.sh
sudo cp /home/ubuntu/airflow.conf //usr/lib/tmpfiles.d

sudo cp /home/ubuntu/airflow-webserver.service /lib/systemd/system/airflow-webserver.service
sudo cp /home/ubuntu/airflow-scheduler.service /lib/systemd/system/airflow-scheduler.service
sudo cp /home/ubuntu/airflow-worker.service /lib/systemd/system/airflow-worker.service

rm /home/ubuntu/airflow.sysconfig
rm /home/ubuntu/airflow.conf

rm /home/ubuntu/airflow-webserver.service
rm /home/ubuntu/airflow-scheduler.service
rm /home/ubuntu/airflow-worker.service
echo "------------------- copy systemd components complete -------------------"

sudo mkdir /run/airflow
sudo chown ubuntu:ubuntu /run/airflow
echo "------------------- modified pid directory complete -------------------"
