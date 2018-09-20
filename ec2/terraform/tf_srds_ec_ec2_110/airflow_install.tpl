#!/bin/bash -xe

mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE DATABASE IF NOT EXISTS ${airflow_dbname} /*\!40100 DEFAULT CHARACTER SET ${airflow_db_charset} */;"
mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE USER '${db_airflow_username}'@'%' IDENTIFIED BY '${db_airflow_password}';"
mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "GRANT ALL PRIVILEGES ON ${airflow_dbname}.* TO '${db_airflow_username}'@'%';"
mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "FLUSH PRIVILEGES;"

export AIRFLOW_HOME=/home/ubuntu/airflow

cd /home/ubuntu/airflow

instance_ip=`curl http://169.254.169.254/latest/meta-data/public-ipv4`

sed -i -e "s/expose_config = False/expose_config = True/g" airflow.cfg
sed -i -e "s/executor = SequentialExecutor/executor = CeleryExecutor/g" airflow.cfg
sed -i -e "s/remote_log_conn_id =/remote_log_conn_id = s3_logging_conn/g" airflow.cfg
sed -i -e "s/load_examples = True/load_examples = False/g" airflow.cfg
sed -i -e "s/authenticate = False/authenticate = True/g" airflow.cfg
sed -i -e "s/base_url = http:\/\/localhost:8080/base_url = http:\/\/$instance_ip:8080/g" airflow.cfg
sed -i -e "s/endpoint_url = http:\/\/localhost:8080/endpoint_url = http:\/\/$instance_ip:8080/g" airflow.cfg
sed -i -e "s/sql_alchemy_conn = sqlite:\/\/\/\/home\/ubuntu\/airflow\/airflow.db/sql_alchemy_conn = mysql:\/\/${db_airflow_username}:${db_airflow_password}@${rds_url}\/${airflow_dbname}/g" airflow.cfg
sed -i -e "s/result_backend = db+mysql:\/\/airflow:airflow@localhost:3306\/airflow/result_backend = redis:\/\/${ec_url}\/0/g" airflow.cfg
sed -i -e "s/broker_url = sqla+mysql:\/\/airflow:airflow@localhost:3306\/airflow/broker_url = redis:\/\/${ec_url}\/1/g" airflow.cfg
sed -i -e "/auth_backend = airflow.api.auth.backend.default/d" airflow.cfg
sed -i -e "/\[webserver\]/a\\
auth_backend = airflow.contrib.auth.backends.password_auth" airflow.cfg
sed -i -e "/remote_base_log_folder/d" airflow.cfg
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

/home/ubuntu/venv/bin/python /home/ubuntu/adduser.py -u ${airflow_username} -e ${airflow_emailaddress} -p ${airflow_password}

id=`id -u`
group=`id -g`

/usr/bin/s3fs ${s3_dag_bucket_name} -o use_cache=/tmp,iam_role="${role_name}",uid=$id,gid=$group /home/ubuntu/airflow/dags