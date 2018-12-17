#!/bin/bash
source /home/ubuntu/.bash_profile
HOSTNAME=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
VARIABLES_INSTALL_FILE=$AIRFLOW_HOME/variables/variables.json
VARIABLES_LOG_FILE=$AIRFLOW_HOME/logs/${HOSTNAME}_variables_install.log
DATESTART=`date`

echo "---------- STARTED AT $DATESTART ----------" >> $VARIABLES_LOG_FILE

echo "---------- STARTING COPY FROM S3 ----------" >> $VARIABLES_LOG_FILE

/home/ubuntu/venv/bin/aws s3 sync s3://$S3_AIRFLOW_BUCKET/variables/ /home/ubuntu/airflow/variables/ --exact-timestamps --delete --quiet

echo "---------- STARTING VARIABLES IMPORT ----------" >> $VARIABLES_LOG_FILE

# verify file exists
if [ -e $VARIABLES_INSTALL_FILE ]
then
    /home/ubuntu/venv/bin/airflow variables --import $VARIABLES_INSTALL_FILE >> $VARIABLES_LOG_FILE
else
    echo "No file found at $VARIABLES_INSTALL_FILE to install." >> $VARIABLES_LOG_FILE
fi

DATEEND=`date`
echo "---------- FINISHED AT $DATEEND ----------" >> $VARIABLES_LOG_FILE
