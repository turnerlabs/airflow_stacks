# What is in the packer directory

The airflow_websched_python2 path contains the code to generate a python 2.7 AMI of an airflow webserver and scheduler that works with Airflow 1.10.0.

The airflow_websched_python3 path contains the code to generate a python 3.6 AMI of an airflow webserver and scheduler that works with Airflow 1.10.0.

The airflow_worker_python2 path contains the code to generate a python 2.7 AMI of an airflow worker that works with Airflow 1.10.0.

The airflow_worker_python3 path contains the code to generate a python 3.6 AMI of an airflow worker that works with Airflow 1.10.0.

The rabbitmq path contains the code to generate an AMI of rabbitmq.

The airflow AMI's also have the following additions / assumptions:

- AIRFLOW_HOME is /home/ubuntu/airflow
- Python uses a virtual environment that can be activated by `source ~/venv/bin/activate`
- The dags directory is located at /home/ubuntu/airflow/dags
- The logs are located at /home/ubuntu/airflow/logs
- The logs are being pushed to cloudwatch logs for easier viewing.
- The logs are being zipped every hour(and removed every 24 hours) via crontab using logrotate.
- The services are using systemd services so you can stop and start the 3 services as follows:
  - `systemctl stop airflow-webserver`
  - `systemctl stop airflow-scheduler`
  - `systemctl stop airflow-worker`