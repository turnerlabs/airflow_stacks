#!/usr/bin/env bash

TRY_LOOP="20"

: "${REDIS_HOST:="redis"}"
: "${REDIS_PORT:="6379"}"
: "${REDIS_PASSWORD:=""}"

: "${MYSQL_HOST:="mysql"}"
: "${MYSQL_PORT:="3306"}"
: "${MYSQL_USER:="airflow"}"
: "${MYSQL_PASSWORD:="airflow"}"
: "${MYSQL_DB:="airflow"}"

# Defaults and back-compat
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(/usr/bin/python3 -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"

generate_config() {
  echo "############# Start generate_config #############"
  airflow initdb
  echo "############# Finished generate_config #############"
}

create_directories() {
  echo "############# Start create_directories #############"
  if [ ! -e "${AIRFLOW_HOME}/dags" ]; then
    mkdir ${AIRFLOW_HOME}/dags
  fi
  if [ ! -e "${AIRFLOW_HOME}/requirements" ]; then
    mkdir ${AIRFLOW_HOME}/requirements
  fi
  if [ ! -e "${AIRFLOW_HOME}/variables" ]; then
    mkdir ${AIRFLOW_HOME}/variables
  fi
  if [ ! -e "${AIRFLOW_HOME}/connections" ]; then
    mkdir ${AIRFLOW_HOME}/connections
  fi
  echo "############# Finished create_directories #############"  
}

update_requirements() {
  echo "############# Start update_requirements #############"
  # Install custom python package if requirements.txt is present
  if [ -e "${AIRFLOW_HOME}/requirements/requirements.txt" ]; then
    $(which pip) install --user -r ${AIRFLOW_HOME}/requirements/requirements.txt
  else
    echo "No requirements.txt file found"
  fi
  echo "############# Finished update_requirements #############"  
}

update_variables() {
  echo "############# Start update_variables #############"
  # Install custom variables if is present
  if [ -e "${AIRFLOW_HOME}/variables/variables.json" ]; then
    airflow variables --import ${AIRFLOW_HOME}/variables/variables.json
  else
    echo "No variables.json file found"
  fi
  echo "############# Finished update_variables #############"  
}

update_connections() {
  echo "############# Start update_connections #############"
  # Install custom connections if is present
  if [ -e "${AIRFLOW_HOME}/connections/connections.json" ]; then
    airflow connections --import ${AIRFLOW_HOME}/connections/connections.json
  else
    echo "No connections.json file found"
  fi
  echo "############# Finished update_connections #############"  
}

update_airflow_config() {
  echo "############# Start update_airflow_config #############"
  if [ -n "$REDIS_PASSWORD" ]; then
      REDIS_PREFIX=:${REDIS_PASSWORD}@
  else
      REDIS_PREFIX=
  fi

  sed -i -e "s/dag_dir_list_interval = 300/dag_dir_list_interval = 60/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/expose_config = False/expose_config = True/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/executor = SequentialExecutor/executor = CeleryExecutor/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/load_examples = True/load_examples = False/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/authenticate = False/authenticate = True/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/filter_by_owner = False/filter_by_owner = True/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/secure_mode = False/secure_mode = True/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/donot_pickle = True/donot_pickle = False/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/enable_xcom_pickling = True/enable_xcom_pickling = False/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/sql_alchemy_conn = sqlite:\/\/\/\/usr\/local\/airflow\/airflow.db/sql_alchemy_conn = mysql:\/\/$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST:$MYSQL_PORT\/$MYSQL_DB/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/result_backend = db+mysql:\/\/airflow:airflow@localhost:3306\/airflow/result_backend = redis:\/\/$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT\/0/g" ${AIRFLOW_HOME}/airflow.cfg
  sed -i -e "s/broker_url = sqla+mysql:\/\/airflow:airflow@localhost:3306\/airflow/broker_url = redis:\/\/$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT\/1/g" ${AIRFLOW_HOME}/airflow.cfg
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
    echo "$(date) - waiting for $name at $host on $port... $j/$TRY_LOOP"
    sleep 5
  done
}

wait_for_dbs(){
  wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"
  wait_for_port "MySQL" "$MYSQL_HOST" "$MYSQL_PORT"
}

generate_user(){
  echo "############# Start generate_user #############"
  airflow create_user -u airflow -e airflow@airflow.com -p airflow -f airflow -l airflow -r Admin
  echo "############# Finished generate_user #############"  
}

case "$1" in
  webserver)
    if [ ! -e "${AIRFLOW_HOME}/airflow.cfg" ]; then
      generate_config # generate using the default 1.10 version config
      update_airflow_config  # update the config with the settings I want to change
      generate_rbac # generate the webserver_config.py
      create_directories # create common directories
      wait_for_dbs # make sure metadata database is running before attempting to initialize
      airflow initdb # reinitilize the config with my settings applied
      sleep 5
      generate_user # create an rbac user after everything is up and running
      sleep 5
    fi

    update_requirements
    update_variables
    update_connections
    exec airflow webserver
    ;;
  worker|scheduler)
    sleep 45 # gotta give the webserver a head start to generate all the files and directories

    update_requirements
    exec airflow "$@"
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac
