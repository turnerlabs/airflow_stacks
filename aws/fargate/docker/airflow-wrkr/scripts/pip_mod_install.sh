#!/bin/bash
source /usr/local/airflow/.bash_profile
HOSTNAME=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
PIP_MODULES_FILE=$AIRFLOW_HOME/requirements/requirements.txt
PIP_LOG_FILE=$AIRFLOW_HOME/logs/${HOSTNAME}_module_install.log
DATESTART=`date`

echo "---------- STARTED AT $DATESTART ----------" >> $PIP_LOG_FILE

echo "---------- STARTING COPY FROM S3 ----------" >> $PIP_LOG_FILE

aws s3 sync s3://$S3_AIRFLOW_BUCKET/requirements/ $AIRFLOW_HOME/requirements/ --exact-timestamps --delete --quiet

echo "---------- STARTING PIP INSTALL ----------" >> $PIP_LOG_FILE

# verify file exists
if [ -e $PIP_MODULES_FILE ]
then
    pip install -qqq --no-color --upgrade --requirement $PIP_MODULES_FILE --log $PIP_LOG_FILE
else
    echo "No file found at $PIP_MODULES_FILE to install." >> $PIP_LOG_FILE
fi

DATEEND=`date`
echo "---------- FINISHED AT $DATEEND ----------" >> $PIP_LOG_FILE
