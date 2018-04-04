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

airflow initdb
echo "------------------- initialize database phase 1 complete -------------------"

cp /home/ubuntu/models.py /home/ubuntu/venv/lib/python2.7/site-packages/airflow/models.py

cp /home/ubuntu/hooks__init__.py /home/ubuntu/venv/lib/python2.7/site-packages/airflow/contrib/hooks/__init__.py
cp /home/ubuntu/snowflake_hook.py /home/ubuntu/venv/lib/python2.7/site-packages/airflow/contrib/hooks/snowflake_hook.py

cp /home/ubuntu/operators__init__.py /home/ubuntu/venv/lib/python2.7/site-packages/airflow/contrib/operators/__init__.py
cp /home/ubuntu/snowflake_operator.py /home/ubuntu/venv/lib/python2.7/site-packages/airflow/contrib/operators/snowflake_operator.py

chmod 644 /home/ubuntu/venv/lib/python2.7/site-packages/airflow/models.py

chmod 664 /home/ubuntu/venv/lib/python2.7/site-packages/airflow/contrib/hooks/__init__.py
chmod 664 /home/ubuntu/venv/lib/python2.7/site-packages/airflow/contrib/hooks/snowflake_hook.py

chmod 664 /home/ubuntu/venv/lib/python2.7/site-packages/airflow/contrib/operators/__init__.py
chmod 664 /home/ubuntu/venv/lib/python2.7/site-packages/airflow/contrib/operators/snowflake_operator.py

rm /home/ubuntu/models.py
rm /home/ubuntu/hooks__init__.py
rm /home/ubuntu/snowflake_hook.py
rm /home/ubuntu/operators__init__.py
rm /home/ubuntu/snowflake_operator.py
echo "------------------- copy snowflake components complete -------------------"

pip install 'sqlalchemy<1.2'
echo "------------------- reset to use an older version of sql alchemy(to use password authentication) complete -------------------"

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

sudo mkdir /run/airflow
sudo chown ubuntu:ubuntu /run/airflow 
