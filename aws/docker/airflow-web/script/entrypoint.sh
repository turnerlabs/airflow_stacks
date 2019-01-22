#!/bin/bash -xe

TRY_LOOP="20"

export AIRFLOW_HOME=/usr/local/airflow

# Defaults and back-compat
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"

generate_config() {
  echo "############# Start generate_config #############"
  airflow initdb
  echo "############# Finished generate_config #############"  
}

update_requirements() {
  # Install custom python package if requirements.txt is present
  if [ -e "${AIRFLOW_HOME}/requirements/requirements.txt" ]; then
      echo "############# Start update_requirements #############"
      $(which pip) install --user -r ${AIRFLOW_HOME}/requirements/requirements.txt
      echo "############# Finished update_requirements #############"      
  fi
}

update_variables() {
  # Install custom variables if is present
  if [ -e "${AIRFLOW_HOME}/variables/variables.json" ]; then
      echo "############# Start update_variables #############"
      airflow variables --import ${AIRFLOW_HOME}/variables/variables.json
      echo "############# Finished update_variables #############"      
  fi
}

update_connections() {
  # Install custom connections if is present
  if [ -e "${AIRFLOW_HOME}/connections/connections.json" ]; then
      echo "############# Start update_connections #############"
      airflow connections --import ${AIRFLOW_HOME}/variables/connections.json
      echo "############# Finished update_connections #############"      
  fi
}

update_airflow_config() {
    echo "############# Start update_airflow_config #############"
    sed -i -e "s/dag_dir_list_interval = 300/dag_dir_list_interval = 120/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/expose_config = False/expose_config = True/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/executor = SequentialExecutor/executor = CeleryExecutor/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/remote_logging = False/remote_logging = True/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/remote_base_log_folder =/remote_base_log_folder = s3:\/\/${S3_AIRFLOW_LOG_BUCKET_NAME}/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/remote_log_conn_id =/remote_log_conn_id = s3:\/\/${S3_AIRFLOW_LOG_BUCKET_NAME}/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/load_examples = True/load_examples = False/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/authenticate = False/authenticate = True/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/filter_by_owner = False/filter_by_owner = True/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/secure_mode = False/secure_mode = True/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/donot_pickle = True/donot_pickle = False/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/enable_xcom_pickling = True/enable_xcom_pickling = False/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/base_url = http:\/\/localhost:8080/base_url = http:\/\/${SUBDOMAIN}/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/endpoint_url = http:\/\/localhost:8080/endpoint_url = http:\/\/${SUBDOMAIN}/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "/sql_alchemy_conn = sqlite:\/\/\/\/home\/ubuntu\/airflow\/airflow.db/d" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "/\[core\]/a\\
sql_alchemy_conn_cmd = ${AIRFLOW_HOME}/connect.sh" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/result_backend = db+mysql:\/\/airflow:airflow@localhost:3306\/airflow/result_backend = redis:\/\/${EC_URL}\/0/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/broker_url = sqla+mysql:\/\/airflow:airflow@localhost:3306\/airflow/broker_url = redis:\/\/${EC_URL}\/1/g" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "/auth_backend = airflow.api.auth.backend.default/d" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "/\[webserver\]/a\\
auth_backend = airflow.contrib.auth.backends.password_auth" ${AIRFLOW_HOME}/airflow.cfg
    sed -i -e "s/rbac = False/rbac = True/g" ${AIRFLOW_HOME}/airflow.cfg
    echo "############# Finished update_airflow_config #############"    
}

generate_rbac(){
  echo "############# Start generate_rbac #############"
  airflow -h
  echo "############# Finished generate_rbac #############"  
}

wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}

wait_for_dbs(){
  wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"
  wait_for_port "MySQL" "$MYSQL_HOST" "$MYSQL_PORT"
}

create_airflow_database(){
  if [ ! -e "${AIRFLOW_HOME}/airflow.cfg" ]; then
    echo "############# Start create_airflow_database #############"
    mysql --host=${RDS_URL} --user=${DB_MASTER_USERNAME} --password=${DB_MASTER_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${DB_AIRFLOW_DBNAME} /*\!40100 DEFAULT CHARACTER SET ${DB_CHARSET} */;"
    mysql --host=${RDS_URL} --user=${DB_MASTER_USERNAME} --password=${DB_MASTER_PASSWORD} -e "CREATE USER '${DB_AIRFLOW_USERNAME}'@'%' IDENTIFIED BY '${DB_AIRFLOW_PASSWORD}';"
    mysql --host=${RDS_URL} --user=${DB_MASTER_USERNAME} --password=${DB_MASTER_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${DB_AIRFLOW_DBNAME}.* TO '${DB_AIRFLOW_USERNAME}'@'%';"
    mysql --host=${RDS_URL} --user=${DB_MASTER_USERNAME} --password=${DB_MASTER_PASSWORD} -e "FLUSH PRIVILEGES;"
    echo "############# Finished create_airflow_database #############"
  fi
}

create_database_connection_script(){
  if [ ! -e "${AIRFLOW_HOME}/connect.sh" ]; then
    echo "############# Start create_database_connection_script #############"  
    echo "#!/bin/bash" >> ${AIRFLOW_HOME}/connect.sh
    echo $'' >> ${AIRFLOW_HOME}/connect.sh
    echo "db_port=\"${DB_PORT}\"" >> ${AIRFLOW_HOME}/connect.sh
    echo "db_region=\"${DB_REGION}\"" >> ${AIRFLOW_HOME}/connect.sh
    echo "db_airflow_dbname=\"${DB_AIRFLOW_DBNAME}\"" >> ${AIRFLOW_HOME}/connect.sh
    echo "db_airflow_username=\"${DB_AIRFLOW_USERNAME}\"" >> ${AIRFLOW_HOME}/connect.sh
    echo "RDS_URL=\"${RDS_URL}\"" >> ${AIRFLOW_HOME}/connect.sh
    echo $'' >> ${AIRFLOW_HOME}/connect.sh
    echo "token=\$(echo \$RDS_KEY)" >> ${AIRFLOW_HOME}/connect.sh
    echo "url=\"mysql://\$DB_AIRFLOW_USERNAME:\$token@\$RDS_URL/\$DB_AIRFLOW_DBNAME"\" >> ${AIRFLOW_HOME}/connect.sh
    echo $'' >> ${AIRFLOW_HOME}/connect.sh
    echo "echo \"\$url"\" >> ${AIRFLOW_HOME}/connect.sh
    aws s3 cp ${AIRFLOW_HOME}/connect.sh s3://${S3_AIRFLOW_BUCKET_NAME}/connect.sh --quiet
    echo "############# Finished create_database_connection_script #############"  
  fi
}

create_secret_manager_script(){
  if [ ! -e "${AIRFLOW_HOME}/sm_update.sh" ]; then
    echo "############# Start create_secret_manager_script #############"
    echo "#!/bin/bash" >> ${AIRFLOW_HOME}/sm_update.sh
    echo $'' >> ${AIRFLOW_HOME}/sm_update.sh
    echo "secret=\`/home/ubuntu/venv/bin/aws secretsmanager get-secret-value --region ${DB_REGION} --secret-id ${AIRFLOW_SECRET}\`" >> ${AIRFLOW_HOME}/sm_update.sh
    echo $'' >> ${AIRFLOW_HOME}/sm_update.sh
    echo "token=\$(echo \$secret | jq -r .SecretString)" >> ${AIRFLOW_HOME}/sm_update.sh
    echo $'' >> ${AIRFLOW_HOME}/sm_update.sh
    echo "sudo sed -i -e \"/RDS_KEY/d\" /etc/environment" >> ${AIRFLOW_HOME}/sm_update.sh
    echo "sudo sed -i -e \"/RDS_KEY/d\" /etc/profile.d/airflow.sh" >> ${AIRFLOW_HOME}/sm_update.sh
    echo "sudo sed -i -e \"$ a RDS_KEY=\$token\" /etc/environment" >> ${AIRFLOW_HOME}/sm_update.sh
    echo "sudo sed -i -e \"$ a RDS_KEY=\$token\" /etc/profile.d/airflow.sh" >> ${AIRFLOW_HOME}/sm_update.sh
    aws s3 cp ${AIRFLOW_HOME}/sm_update.sh s3://${S3_AIRFLOW_BUCKET_NAME}/sm_update.sh --quiet
    echo "############# Finished create_secret_manager_script #############"
  fi  
}

set_secret_manager_values(){
  echo "############# Start set_secret_manager_values  #############"
  secret=`aws secretsmanager get-secret-value --region ${DB_REGION} --secret-id ${AIRFLOW_SECRET}`
  token=$(echo $secret | jq -r .SecretString)
  echo "RDS_KEY=$token" >> /etc/environment
  echo "RDS_KEY=$token" >> /etc/profile.d/airflow.sh
  export RDS_KEY=$token
  echo "############# Finished set_secret_manager_values  #############"
}

set_environment_values(){
  echo "############# Start set_environment_values  #############"
  echo $'' >> /etc/ENVIRONMENT
  echo $'' >> /etc/profile.d/airflow.sh
  echo "S3_AIRFLOW_BUCKET=${S3_AIRFLOW_BUCKET_NAME}" >> /etc/environment
  echo "S3_AIRFLOW_BUCKET=${S3_AIRFLOW_BUCKET_NAME}" >> /etc/profile.d/airflow.sh
  export S3_AIRFLOW_BUCKET=${S3_AIRFLOW_BUCKET_NAME}
  echo "############# Finished set_environment_values  #############"
}

download_config_files(){
  echo "############# Start download_config_files  #############"
  aws s3 cp s3://${S3_AIRFLOW_BUCKET_NAME}/ ${AIRFLOW_HOME}/ --recursive --quiet
  echo "############# Finished download_config_files  #############"
}

upload_config_files(){
  if [ ! -e "${AIRFLOW_HOME}/airflow.cfg" ]; then
    echo "############# Start upload_config_files  #############"
    /home/ubuntu/venv/bin/aws s3 cp ${AIRFLOW_HOME}/airflow.cfg s3://${S3_AIRFLOW_BUCKET_NAME}/airflow.cfg --quiet
    /home/ubuntu/venv/bin/aws s3 cp ${AIRFLOW_HOME}/unittests.cfg s3://${S3_AIRFLOW_BUCKET_NAME}/unittests.cfg --quiet
    /home/ubuntu/venv/bin/aws s3 cp ${AIRFLOW_HOME}/webserver_config.py s3://${S3_AIRFLOW_BUCKET_NAME}/webserver_config.py --quiet
    echo "############# Finished upload_config_files  #############"
  fi
}

update_file_permissions(){
  echo "############# Start update_file_permissions  #############"
  chown -R ubuntu:ubuntu ${AIRFLOW_HOME}
  chmod 700 ${AIRFLOW_HOME}/connect.sh
  chmod 700 ${AIRFLOW_HOME}/sm_update.sh
  chmod 600 ${AIRFLOW_HOME}/airflow.cfg
  chmod 600 ${AIRFLOW_HOME}/unittests.cfg
  chmod 600 ${AIRFLOW_HOME}/webserver_config.py
  echo "############# Finished update_file_permissions  #############"
}

generate_user(){
  echo "############# Start generate_user #############"
  airflow create_user -u ${AIRFLOW_USERNAME} -e ${AIRFLOW_EMAILADDRESS} -p ${AIRFLOW_PASSWORD} -f ${AIRFLOW_FIRST} -l ${AIRFLOW_LAST} -r ${AIRFLOW_ROLE}
  echo "############# Finished generate_user #############"  
}

case "$1" in
  webserver)
    set_environment_values
    set_secret_manager_values
    download_config_files
    if [ ! -e "${AIRFLOW_HOME}/airflow.cfg" ]; then
      create_airflow_database
      create_database_connection_script
      create_secret_manager_script
      generate_config # generate using the default 1.10 version config
      sleep 5
      update_config  # update the config with the settings I want to change
      sleep 5
      generate_rbac # generate the webserver_config.py
      sleep 5
      mkdir ${AIRFLOW_HOME}/dags
      wait_for_dbs # make sure metadata database is running before attempting to initialize
      sleep 5
      airflow initdb # reinitilize the config with my settings applied
      sleep 5
      generate_user # create an rbac user after everything is up and running
      upload_config_files
      sleep 5
    fi

    update_file_permissions
    update_requirements
    update_variables
    update_connections
    /etc/init.d/chrony restart
    exec airflow webserver
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac
