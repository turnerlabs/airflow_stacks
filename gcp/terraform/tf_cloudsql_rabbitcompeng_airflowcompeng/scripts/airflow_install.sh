#!/bin/bash -xe

systemctl enable cloud-sql-proxy

systemctl daemon-reload

systemctl start cloud-sql-proxy

mysql --host=127.0.0.1 --user=airflow-master --password=${db_master_password} -e "CREATE DATABASE IF NOT EXISTS airflow /*\!40100 DEFAULT CHARACTER SET latin1 */;"
mysql --host=127.0.0.1 --user=airflow-master --password=${db_master_password} -e "CREATE USER IF NOT EXISTS 'airflow'@'%' IDENTIFIED BY '${db_airflow_password}';"
mysql --host=127.0.0.1 --user=airflow-master --password=${db_master_password} -e "GRANT ALL PRIVILEGES ON airflow.* TO 'airflow'@'%';"
mysql --host=127.0.0.1 --user=airflow-master --password=${db_master_password} -e "FLUSH PRIVILEGES;"

export AIRFLOW_HOME=/home/ubuntu/airflow

cd /home/ubuntu/airflow

sed -i -e "s/expose_config = False/expose_config = True/g" airflow.cfg
sed -i -e "s/load_examples = True/load_examples = False/g" airflow.cfg
sed -i -e "s/authenticate = False/authenticate = True/g" airflow.cfg
sed -i -e "s/sql_alchemy_conn = sqlite:\/\/\/\/home\/ubuntu\/airflow\/airflow.db/sql_alchemy_conn = mysql:\/\/airflow:${db_airflow_password}@127.0.0.1\/airflow/g" airflow.cfg
sed -i -e "/auth_backend = airflow.api.auth.backend.default/d" airflow.cfg
sed -i -e "/\[webserver\]/a\\
auth_backend = airflow.contrib.auth.backends.password_auth" airflow.cfg

/home/ubuntu/venv/bin/airflow initdb

systemctl enable airflow-webserver

systemctl daemon-reload

systemctl start airflow-webserver

/home/ubuntu/venv/bin/python /home/ubuntu/adduser.py -u airflow -e ${airflow_emailaddress} -p ${airflow_password}