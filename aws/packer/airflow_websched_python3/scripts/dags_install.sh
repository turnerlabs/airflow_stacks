#!/bin/bash
source /home/ubuntu/.bash_profile
HOSTNAME=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
DAGS_DIRECTORY=$AIRFLOW_HOME/dags
DAGS_LOG_FILE=$AIRFLOW_HOME/logs/${HOSTNAME}_dags_install.log
DATESTART=`date`

echo "---------- STARTED AT $DATESTART ----------" >> $DAGS_LOG_FILE

echo "---------- STARTING COPY FROM S3 ----------" >> $DAGS_LOG_FILE

/home/ubuntu/venv/bin/aws s3 sync s3://$S3_AIRFLOW_BUCKET/dags/ /home/ubuntu/airflow/dags/ --exact-timestamps --delete --quiet --exclude __pycache__

DATEEND=`date`
echo "---------- FINISHED AT $DATEEND ----------" >> $DAGS_LOG_FILE
