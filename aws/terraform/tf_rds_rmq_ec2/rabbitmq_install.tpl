#!/bin/bash -xe

rabbitmqctl add_user ${rabbitmq_admin_username} ${rabbitmq_admin_password}
rabbitmqctl set_user_tags ${rabbitmq_admin_username} administrator
rabbitmqctl set_permissions -p / ${rabbitmq_admin_username} ".*" ".*" ".*"

rabbitmqctl add_user ${rabbitmq_airflow_username} ${rabbitmq_airflow_password}
rabbitmqctl add_vhost airflowhost
rabbitmqctl set_user_tags ${rabbitmq_airflow_username} airflowuser
rabbitmqctl set_permissions -p airflowhost ${rabbitmq_airflow_username} ".*" ".*" "."
rabbitmqctl set_permissions -p airflowhost ${rabbitmq_admin_username} ".*" ".*" ".*"
