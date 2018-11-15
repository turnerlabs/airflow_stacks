#!/bin/bash
source /home/ubuntu/.bash_profile
HOSTNAME=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
PIP_MODULES_FILE=$AIRFLOW_HOME/requirements/requirements.txt
PIP_LOG_FILE=$AIRFLOW_HOME/logs/${HOSTNAME}_module_install.log
DATESTART=`date`

echo "---------- STARTED at $DATESTART ----------" >> $PIP_LOG_FILE

# verify file exists
if [ -e $PIP_MODULES_FILE ]
then
    /home/ubuntu/venv/bin/pip install -qqq --no-color --upgrade --requirement $PIP_MODULES_FILE --log $PIP_LOG_FILE
else
    echo "No file found at $PIP_MODULES_FILE to install." >> $PIP_LOG_FILE
fi

DATEEND=`date`
echo "---------- FINISHED at $DATEEND ----------" >> $PIP_LOG_FILE
