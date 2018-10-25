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
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"

generate_config() {
  airflow initdb
}

update_config() {
  # Install custom python package if requirements.txt is present
  if [ -e "/requirements.txt" ]; then
      $(which pip) install --user -r /requirements.txt
  fi

  if [ -n "$REDIS_PASSWORD" ]; then
      REDIS_PREFIX=:${REDIS_PASSWORD}@
  else
      REDIS_PREFIX=
  fi

  sed -i -e "s/filter_by_owner = False/filter_by_owner = True/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/expose_config = False/expose_config = True/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/executor = SequentialExecutor/executor = CeleryExecutor/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/load_examples = True/load_examples = False/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/authenticate = False/authenticate = True/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/secure_mode = False/secure_mode = True/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/donot_pickle = True/donot_pickle = False/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/enable_xcom_pickling = True/enable_xcom_pickling = False/g" /usr/local/airflow/airflow/airflow.cfg
  #sed -i -e "s/base_url = http:\/\/localhost:8080/base_url = http:\/\/$instance_ip:8080/g" /usr/local/airflow/airflow/airflow.cfg
  #sed -i -e "s/endpoint_url = http:\/\/localhost:8080/endpoint_url = http:\/\/$instance_ip:8080/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/sql_alchemy_conn = sqlite:\/\/\/\/usr\/local\/airflow\/airflow\/airflow.db/sql_alchemy_conn = mysql:\/\/$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST:$MYSQL_PORT\/$MYSQL_DB/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/result_backend = db+mysql:\/\/airflow:airflow@localhost:3306\/airflow/result_backend = redis:\/\/$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT\/0/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/broker_url = sqla+mysql:\/\/airflow:airflow@localhost:3306\/airflow/broker_url = redis:\/\/$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT\/1/g" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "/auth_backend = airflow.api.auth.backend.default/d" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "/\[webserver\]/a\\
auth_backend = airflow.contrib.auth.backends.password_auth" /usr/local/airflow/airflow/airflow.cfg
  sed -i -e "s/rbac = False/rbac = True/g" /usr/local/airflow/airflow/airflow.cfg
}

generate_rbac(){
  airflow -h
  # the rbac code needs the file in /usr/local/airflow not /usr/local/airflow/airflow
  cp /usr/local/airflow/airflow/webserver_config.py /usr/local/airflow/webserver_config.py
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

generate_user(){
  airflow create_user -u airflow -e airflow@airflow.com -p airflow -f airflow -l airflow -r Admin
}

case "$1" in
  webserver)
    generate_config # generate using the default 1.10 version config
    sleep 5
    update_config  # update the config with the settings I want to change
    sleep 5
    generate_rbac # generate the webserver_config.py
    sleep 5
    wait_for_dbs # make sure metadata database is running before attempting to initialize
    sleep 5
    airflow initdb # reinitilize the config with my settings applied
    sleep 5
    generate_user # create an rbac user after everything is up and running
    sleep 5
    exec airflow webserver
    ;;
  worker|scheduler)
    # need to give the webserver time to run initdb.
    sleep 35
    exec airflow "$@"
    ;;
  flower)
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
