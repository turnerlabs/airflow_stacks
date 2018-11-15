#!/bin/bash
source /home/ubuntu/.bash_profile
HOSTNAME=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
VARIABLES_INSTALL_FILE=$AIRFLOW_HOME/variables/variables.json
VARIABLES_LOG_FILE=$AIRFLOW_HOME/logs/${HOSTNAME}_variables_install.log
DATESTART=`date`

echo "---------- STARTED at $DATESTART ----------" >> $VARIABLES_LOG_FILE

# verify file exists
if [ -e $VARIABLES_INSTALL_FILE ]
then
    /home/ubuntu/venv/bin/airflow variables --import $VARIABLES_INSTALL_FILE >> $VARIABLES_LOG_FILE
else
    echo "No file found at $VARIABLES_INSTALL_FILE to install." >> $VARIABLES_LOG_FILE
fi

DATEEND=`date`
echo "---------- FINISHED at $DATEEND ----------" >> $VARIABLES_LOG_FILE
