#!/bin/bash -xe

mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE DATABASE IF NOT EXISTS ${airflow_dbname} /*\!40100 DEFAULT CHARACTER SET ${airflow_db_charset} */;"
mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE USER IF NOT EXISTS '${db_airflow_username}'@'%' IDENTIFIED BY '${db_airflow_password}';"
mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "GRANT ALL PRIVILEGES ON ${airflow_dbname}.* TO '${db_airflow_username}'@'%';"
mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "FLUSH PRIVILEGES;"

export AIRFLOW_HOME=/home/ubuntu/airflow

cd /home/ubuntu/airflow

sed -i -e "s/executor = SequentialExecutor/executor = CeleryExecutor/g" airflow.cfg
sed -i -e "s/remote_log_conn_id =/remote_log_conn_id = s3_logging_conn/g" airflow.cfg
sed -i -e "s/load_examples = True/load_examples = False/g" airflow.cfg
sed -i -e "s/authenticate = False/authenticate = True/g" airflow.cfg
sed -i -e "s/sql_alchemy_conn = sqlite:\/\/\/\/home\/ubuntu\/airflow\/airflow.db/sql_alchemy_conn = mysql:\/\/${db_airflow_username}:${db_airflow_password}@${rds_url}\/${airflow_dbname}/g" airflow.cfg
sed -i -e "s/celery_result_backend = db+mysql:\/\/airflow:airflow@localhost:3306\/airflow/celery_result_backend = db+mysql:\/\/${db_airflow_username}:${db_airflow_password}@${rds_url}\/${airflow_dbname}/g" airflow.cfg
sed -i -e "s/broker_url = sqla+mysql:\/\/airflow:airflow@localhost:3306\/airflow/broker_url = amqp:\/\/${rabbitmq_airflow_username}:${rabbitmq_airflow_password}@${rabbitmq_ip_address}\/airflowhost/g" airflow.cfg
sed -i -e "/auth_backend = airflow.api.auth.backend.default/d" airflow.cfg
sed -i -e "/\[webserver\]/a\\
auth_backend = airflow.contrib.auth.backends.password_auth" airflow.cfg
sed -i -e "/\[core\]/a\\
remote_base_log_folder = s3://${s3_log_bucket_name}" airflow.cfg

/home/ubuntu/venv/bin/airflow initdb

systemctl enable airflow-webserver
systemctl enable airflow-scheduler
systemctl enable airflow-worker

systemctl daemon-reload

systemctl start airflow-webserver
systemctl start airflow-scheduler
systemctl start airflow-worker

/home/ubuntu/venv/bin/python /home/ubuntu/adduser.py -u airflow -e airflow@turner.com -p airflowpassword