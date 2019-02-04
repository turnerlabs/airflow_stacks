#!/bin/bash -xe

TRY_LOOP="50"

set_environment_values(){
  echo "############# Start set_environment_values  #############"
  echo $'' >> /etc/environment
  echo $'' >> /etc/profile.d/airflow.sh
  echo "S3_AIRFLOW_BUCKET=${S3_AIRFLOW_BUCKET_NAME}" >> /etc/environment
  echo "S3_AIRFLOW_BUCKET=${S3_AIRFLOW_BUCKET_NAME}" >> /etc/profile.d/airflow.sh
  export S3_AIRFLOW_BUCKET=${S3_AIRFLOW_BUCKET_NAME}
  echo "############# Finished set_environment_values  #############"
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

download_config_files(){
  echo "############# Start download_config_files  #############"
  aws s3 cp s3://${S3_AIRFLOW_BUCKET_NAME}/ ${AIRFLOW_HOME}/ --recursive --quiet
  echo "############# Finished download_config_files  #############"
}

wait_for_dbs(){
  wait_for_port "airflow_webserver" "${SUBDOMAIN}" "443"
}

update_file_permissions(){
  echo "############# Start update_file_permissions  #############"
  chown -R airflow:airflow ${AIRFLOW_HOME}
  if [ -e "${AIRFLOW_HOME}/connect.sh" ]; then
    chmod 700 ${AIRFLOW_HOME}/connect.sh
  fi
  if [ -e "${AIRFLOW_HOME}/sm_update.sh" ]; then
    chmod 700 ${AIRFLOW_HOME}/sm_update.sh
  fi
  if [ -e "${AIRFLOW_HOME}/airflow.cfg" ]; then
    chmod 600 ${AIRFLOW_HOME}/airflow.cfg
  fi
  if [ -e "${AIRFLOW_HOME}/unittests.cfg" ]; then
    chmod 600 ${AIRFLOW_HOME}/unittests.cfg
  fi
  if [ -e "${AIRFLOW_HOME}/webserver_config.py" ]; then
    chmod 600 ${AIRFLOW_HOME}/webserver_config.py
  fi
  echo "############# Finished update_file_permissions  #############"
}

update_requirements() {
  # Install custom python package if requirements.txt is present
  if [ -e "${AIRFLOW_HOME}/requirements/requirements.txt" ]; then
      echo "############# Start update_requirements #############"
      $(which pip) install --user -r ${AIRFLOW_HOME}/requirements/requirements.txt
      echo "############# Finished update_requirements #############"      
  fi
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
    echo "$(date) - waiting for $name at $host on $port... $j/$TRY_LOOP"
    sleep 5
  done
}

case "$1" in
  worker)
    set_environment_values
    set_secret_manager_values
    download_config_files
    if [ ! -e "${AIRFLOW_HOME}/airflow.cfg" ]; then
      wait_for_dbs # make sure metadata database is running before attempting to initialize
    fi

    update_file_permissions
    update_requirements

    /etc/init.d/chrony restart
    su - airflow
    exec airflow worker
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac
