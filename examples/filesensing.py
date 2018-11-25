from airflow import DAG
from airflow.contrib.sensors.file_sensor import FileSensor
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

seven_days_ago = datetime.combine(datetime.today() - timedelta(1),
                                  datetime.min.time())

default_args = {
    'owner': 'local',
    'depends_on_past': False,
    'start_date': seven_days_ago,
    'email': ['local@gmail.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG('local_file_sensor', default_args=default_args, schedule_interval='@daily')

t1 = FileSensor(
    task_id='local_file_test',
    filepath="/usr/local/airflow/airflow/requirements/requirements.txt",
    fs_conn_id='fs_default',
    dag=dag)

t2 = BashOperator(
    task_id='task2',
    depends_on_past=False,
    bash_command='echo a big hadoop job putting files locally',
    trigger_rule='all_failed',
    dag=dag)

t2.set_upstream(t1)
