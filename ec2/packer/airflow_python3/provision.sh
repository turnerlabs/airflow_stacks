#!/usr/bin/bash -x

set -e

sudo apt-get -y update
echo "------------------- apt update complete -------------------"

sudo apt-get -y install unattended-upgrades
echo "------------------- apt upgrade complete -------------------"

sudo add-apt-repository -y ppa:jonathonf/python-3.6
sudo apt-get -y update

sudo apt-get -y install python-setuptools libmysqlclient-dev libmysqld-dev gcc g++ virtualenv python-dev python3.6-dev mysql-client-core-5.7 python3.6 default-jre libc6-i386 unixodbc freetds-dev freetds-bin tdsodbc libcurl3 default-jre libc6-i386 apt-transport-https python3-gdbm \

echo "------------------- airflow aptitude dependencies complete -------------------"

sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 3

echo "export AIRFLOW_HOME=/home/ubuntu/airflow" >> /home/ubuntu/.bash_profile
echo "------------------- append AIRFLOW_HOME to bash profile complete -------------------"

export AIRFLOW_HOME=/home/ubuntu/airflow

virtualenv -p `which python3` venv
echo "------------------- virtual environment creation complete -------------------"

source ~/venv/bin/activate
echo "------------------- activate virtual environment complete -------------------"

pip install --upgrade pip
echo "------------------- pip upgrade complete -------------------"

pip install html5lib 'boto3<1.7' markupsafe flask_bcrypt snowflake-connector-python celery 'zope.deprecation<5.0' jaydebeapi
echo "------------------- install python packages that are needed complete -------------------"

export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=1

pip install "apache-airflow[all]"
echo "------------------- install airflow complete -------------------"

airflow initdb
echo "------------------- initialize database phase 1 complete -------------------"

cp /home/ubuntu/models.py /home/ubuntu/venv/lib/python3.6/site-packages/airflow/models.py

cp /home/ubuntu/hooks__init__.py /home/ubuntu/venv/lib/python3.6/site-packages/airflow/contrib/hooks/__init__.py
cp /home/ubuntu/snowflake_hook.py /home/ubuntu/venv/lib/python3.6/site-packages/airflow/contrib/hooks/snowflake_hook.py

cp /home/ubuntu/operators__init__.py /home/ubuntu/venv/lib/python3.6/site-packages/airflow/contrib/operators/__init__.py
cp /home/ubuntu/snowflake_operator.py /home/ubuntu/venv/lib/python3.6/site-packages/airflow/contrib/operators/snowflake_operator.py

chmod 664 /home/ubuntu/venv/lib/python3.6/site-packages/airflow/models.py

chmod 664 /home/ubuntu/venv/lib/python3.6/site-packages/airflow/contrib/hooks/__init__.py
chmod 664 /home/ubuntu/venv/lib/python3.6/site-packages/airflow/contrib/hooks/snowflake_hook.py

chmod 664 /home/ubuntu/venv/lib/python3.6/site-packages/airflow/contrib/operators/__init__.py
chmod 664 /home/ubuntu/venv/lib/python3.6/site-packages/airflow/contrib/operators/snowflake_operator.py

rm /home/ubuntu/models.py
rm /home/ubuntu/hooks__init__.py
rm /home/ubuntu/snowflake_hook.py
rm /home/ubuntu/operators__init__.py
rm /home/ubuntu/snowflake_operator.py
echo "------------------- snowflake components complete -------------------"

pip install 'sqlalchemy<1.2'
echo "------------------- reset to use an older version of sql alchemy(to use password authentication) complete -------------------"

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
echo "------------------- download aws logs -------------------"

sudo python ./awslogs-agent-setup.py -n -r us-east-1 -c /home/ubuntu/awslogs.conf
echo "------------------- install aws logs -------------------"

mkdir /home/ubuntu/airflow/dags
echo "------------------- create dag and plugins directory complete -------------------"

mkdir /home/ubuntu/airflow/drivers
cp /home/ubuntu/snowflake-jdbc-3.5.4.jar /home/ubuntu/airflow/drivers/snowflake-jdbc-3.5.4.jar

cp /home/ubuntu/jdbc_hook.py /home/ubuntu/venv/lib/python3.6/site-packages/airflow/hooks/jdbc_hook.py
chmod 664 /home/ubuntu/venv/lib/python3.6/site-packages/airflow/hooks/jdbc_hook.py

rm /home/ubuntu/jdbc_hook.py
rm /home/ubuntu/snowflake-jdbc-3.5.4.jar
echo "------------------- jdbc components complete -------------------"

sudo ACCEPT_EULA=Y dpkg -i /home/ubuntu/msodbcsql17_17.1.0.1-1_amd64.deb
sudo apt-get -fyqq install
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
sudo apt-get update -yqq
sudo ACCEPT_EULA=Y apt-get install -yqq python3-gdbm unixodbc-dev mssql-tools
pip install pyodbc
rm /home/ubuntu/msodbcsql17_17.1.0.1-1_amd64.deb
echo "------------------- odbc components complete -------------------"

sudo service awslogs start
echo "------------------- start of awslogs complete -------------------"

sudo systemctl enable awslogs
echo "------------------- enable autostart of awslogs complete -------------------"

crontab -u ubuntu /home/ubuntu/crontab
echo "------------------- enable logs cleanup complete -------------------"

sudo cp /home/ubuntu/airflow.sysconfig /etc/profile.d/airflow.sh
sudo cp /home/ubuntu/airflow.conf /usr/lib/tmpfiles.d

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

pip install --upgrade jsonpatch

cd /home/ubuntu
wget https://launchpad.net/cloud-init/trunk/18.2/+download/cloud-init-18.2.tar.gz
tar -zxvf /home/ubuntu/cloud-init-18.2.tar.gz
cd /home/ubuntu/cloud-init-18.2/
python setup.py build
python setup.py install --init-system systemd
sudo cp /home/ubuntu/venv/bin/cloud-init /usr/bin/cloud-init
echo "------------------- cloud init fix -------------------"