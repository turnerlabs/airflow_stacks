#!/bin/bash -xe

mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE DATABASE IF NOT EXISTS ${db_airflow_dbname} /*\!40100 DEFAULT CHARACTER SET ${db_charset} */;"
mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE USER '${db_airflow_username}'@'%' IDENTIFIED BY '${db_airflow_password}';"
mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "GRANT ALL PRIVILEGES ON ${db_airflow_dbname}.* TO '${db_airflow_username}'@'%';"
mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "FLUSH PRIVILEGES;"

echo "############# Completed database setup #############"

mkdir /home/ubuntu/airflow
chown ubuntu:ubuntu /home/ubuntu/airflow

echo "############# Created airflow directory #############"

id=`id -u ubuntu`
group=`id -g ubuntu`

/usr/bin/s3fs ${s3_airflow_bucket_name} -o use_cache=/tmp,rw,noatime,iam_role="${role_name}",uid=$id,gid=$group,allow_other /home/ubuntu/airflow

echo "############# Enabled s3 mount for airflow directory #############"

export AIRFLOW_HOME=/home/ubuntu/airflow

cd /home/ubuntu/airflow

mkdir /home/ubuntu/airflow/dags
chown ubuntu:ubuntu /home/ubuntu/airflow/dags
mkdir /home/ubuntu/airflow/data
chown ubuntu:ubuntu /home/ubuntu/airflow/data
mkdir /home/ubuntu/airflow/logs
chown ubuntu:ubuntu /home/ubuntu/airflow/logs
mkdir /home/ubuntu/airflow/plugins
chown ubuntu:ubuntu /home/ubuntu/airflow/plugins

echo "############# create common airflow directories complete #############"

/home/ubuntu/venv/bin/airflow initdb

echo "############# Initial airflow database initialization #############"

echo "#!/bin/bash" >> /home/ubuntu/airflow/connect.sh
echo $'' >> /home/ubuntu/airflow/connect.sh
echo "db_port=\"${db_port}\"" >> /home/ubuntu/airflow/connect.sh
echo "db_region=\"${db_region}\"" >> /home/ubuntu/airflow/connect.sh
echo "db_airflow_dbname=\"${db_airflow_dbname}\"" >> /home/ubuntu/airflow/connect.sh
echo "db_airflow_username=\"${db_airflow_username}\"" >> /home/ubuntu/airflow/connect.sh
echo "rds_url=\"${rds_url}\"" >> /home/ubuntu/airflow/connect.sh
echo $'' >> /home/ubuntu/airflow/connect.sh
echo "secret=\`/home/ubuntu/venv/bin/aws secretsmanager get-secret-value --region ${db_region} --secret-id ${airflow_secret}\`" >> /home/ubuntu/airflow/connect.sh
echo "token=\$(echo \$secret | jq -r .SecretString)" >> /home/ubuntu/airflow/connect.sh
echo "url=\"mysql://\$db_airflow_username:\$token@\$rds_url/\$db_airflow_dbname"\" >> /home/ubuntu/airflow/connect.sh
echo $'' >> /home/ubuntu/airflow/connect.sh
echo "echo \"\$url"\" >> /home/ubuntu/airflow/connect.sh

chmod 700 /home/ubuntu/airflow/connect.sh

echo "############# Generate connect.sh #############"

sed -i -e "s/expose_config = False/expose_config = True/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/executor = SequentialExecutor/executor = CeleryExecutor/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/remote_logging = False/remote_logging = True/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/remote_base_log_folder =/remote_base_log_folder = s3:\/\/${s3_airflow_log_bucket_name}/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/remote_log_conn_id =/remote_log_conn_id = s3:\/\/${s3_airflow_log_bucket_name}/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/load_examples = True/load_examples = False/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/authenticate = False/authenticate = True/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/filter_by_owner = False/filter_by_owner = True/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/secure_mode = False/secure_mode = True/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/donot_pickle = True/donot_pickle = False/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/enable_xcom_pickling = True/enable_xcom_pickling = False/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/base_url = http:\/\/localhost:8080/base_url = http:\/\/${subdomain}/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/endpoint_url = http:\/\/localhost:8080/endpoint_url = http:\/\/${subdomain}/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "/sql_alchemy_conn = sqlite:\/\/\/\/home\/ubuntu\/airflow\/airflow.db/d" /home/ubuntu/airflow/airflow.cfg
sed -i -e "/\[core\]/a\\
sql_alchemy_conn_cmd = /home/ubuntu/airflow/connect.sh" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/result_backend = db+mysql:\/\/airflow:airflow@localhost:3306\/airflow/result_backend = redis:\/\/${ec_url}\/0/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/broker_url = sqla+mysql:\/\/airflow:airflow@localhost:3306\/airflow/broker_url = redis:\/\/${ec_url}\/1/g" /home/ubuntu/airflow/airflow.cfg
sed -i -e "/auth_backend = airflow.api.auth.backend.default/d" /home/ubuntu/airflow/airflow.cfg
sed -i -e "/\[webserver\]/a\\
auth_backend = airflow.contrib.auth.backends.password_auth" /home/ubuntu/airflow/airflow.cfg
sed -i -e "s/rbac = False/rbac = True/g" /home/ubuntu/airflow/airflow.cfg

/home/ubuntu/venv/bin/airflow -h

echo "############# Generate webserver_config.py before initdb  #############"

/home/ubuntu/venv/bin/airflow initdb

echo "############# Completed airflow database initilaization #############"

/home/ubuntu/venv/bin/airflow create_user -u ${airflow_username} -e ${airflow_emailaddress} -p ${airflow_password} -f ${airflow_first} -l ${airflow_last} -r ${airflow_role}

echo "############# Added airflow user #############"

systemctl enable airflow-webserver
systemctl enable airflow-scheduler

systemctl daemon-reload

echo "############# Enabled airflow systemd #############"

systemctl start airflow-webserver
systemctl start airflow-scheduler

echo "############# Started up airflow service #############"