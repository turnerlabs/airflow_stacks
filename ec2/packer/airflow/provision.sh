#!/usr/bin/bash -x

set -e

sudo apt-get -y update
echo "------------------- apt update complete -------------------"

sudo apt-get -y install unattended-upgrades
echo "------------------- apt upgrade complete -------------------"

sudo apt-get -y install python-setuptools libmysqlclient-dev libmysqld-dev gcc g++ virtualenv python-dev python3-dev mysql-client-core-5.7
echo "------------------- airflow aptitude dependencies complete -------------------"

echo "export AIRFLOW_HOME=/home/ubuntu/airflow" >> /home/ubuntu/.bash_profile
echo "------------------- append AIRFLOW_HOME to bash profile complete -------------------"

export AIRFLOW_HOME=/home/ubuntu/airflow

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

pip install 'sqlalchemy<1.2'
echo "------------------- reset to use an older version of sql alchemy(to use password authentication) complete -------------------"

airflow initdb
echo "------------------- initialize database phase 1 complete -------------------"

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
echo "------------------- download aws logs -------------------"

sudo python ./awslogs-agent-setup.py -n -r us-east-1 -c /home/ubuntu/awslogs.conf
echo "------------------- install aws logs -------------------"

mkdir /home/ubuntu/airflow/dags
mkdir /home/ubuntu/airflow/plugins
echo "------------------- create dag and plugins directory complete -------------------"

cp /home/ubuntu/snowflake_hook.py /home/ubuntu/airflow/plugins
echo "------------------- copy snowflake complete -------------------"

sudo service awslogs start
echo "------------------- start of awslogs complete -------------------"

sudo systemctl enable awslogs
echo "------------------- enable autostart of awslogs complete -------------------"

crontab -u ubuntu /home/ubuntu/crontab
echo "------------------- enable logs cleanup complete -------------------"
