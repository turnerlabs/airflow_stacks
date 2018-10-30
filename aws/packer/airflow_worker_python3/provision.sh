#!/usr/bin/bash -x

set -e

sudo apt-get -y update
echo "------------------- apt update complete -------------------"

sudo apt-get -y install unattended-upgrades
echo "------------------- apt upgrade complete -------------------"

sudo apt-get -y install chrony jq virtualenv python3-pip libmysqlclient-dev python3-dev python3 libkrb5-dev libsasl2-dev mysql-client-core-5.7 python3-gdbm s3fs redis-tools openjdk-8-jre
echo "------------------- airflow aptitude dependencies complete -------------------"

sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1

echo "export AIRFLOW_HOME=/home/ubuntu/airflow" >> /home/ubuntu/.bash_profile

echo "------------------- append environment variables to bash profile complete -------------------"

export AIRFLOW_HOME=/home/ubuntu/airflow
export SLUGIFY_USES_TEXT_UNIDECODE=yes

pip3 install --upgrade pip
echo "------------------- pip upgrade complete -------------------"

virtualenv -p `which python3` venv
echo "------------------- virtual environment creation complete -------------------"

source ~/venv/bin/activate
echo "------------------- activate virtual environment complete -------------------"

pip install "awscli"
pip install "apache-airflow[all]"
echo "------------------- install airflow complete -------------------"

pip uninstall -y Flask-AppBuilder
pip install Flask-AppBuilder==1.11.1
echo "------------------- Bug fix for Flask AppBuilder  -------------------"

sudo sed -i '1 i\server 169.254.169.123 prefer iburst'  /etc/chrony/chrony.conf
echo "------------------- add ip for aws time services -------------------"

sudo /etc/init.d/chrony restart
echo "------------------- start chrony -------------------"

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
echo "------------------- download aws logs -------------------"

sudo python3 ./awslogs-agent-setup.py -n -r us-east-1 -c /home/ubuntu/awslogs.conf
echo "------------------- install aws logs -------------------"

sudo service awslogs start
echo "------------------- start of awslogs complete -------------------"

sudo systemctl enable awslogs
echo "------------------- enable autostart of awslogs complete -------------------"

crontab -u ubuntu /home/ubuntu/crontab
echo "------------------- enable logs cleanup complete -------------------"

sudo cp /home/ubuntu/airflow.sysconfig /etc/profile.d/airflow.sh
sudo cp /home/ubuntu/airflow.conf /usr/lib/tmpfiles.d

sudo cp /home/ubuntu/airflow-worker.service /lib/systemd/system/airflow-worker.service

rm /home/ubuntu/airflow.sysconfig
rm /home/ubuntu/airflow.conf

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