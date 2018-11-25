from airflow import DAG
from airflow.operators.sensors import S3KeySensor
from airflow.operators import BashOperator
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

dag = DAG('s3_file_sensor', default_args=default_args, schedule_interval='@daily')

t1 = S3KeySensor(
    task_id='s3_file_test',
    poke_interval=0,
    timeout=10,
    soft_fail=True,
    bucket_key='s3://dev.canopydata.com/airflow/example_qubole_operator.py',
    bucket_name=None,
    dag=dag)

t2 = BashOperator(
    task_id='task2',
    depends_on_past=False,
    bash_command='echo a big hadoop job putting files on s3',
    trigger_rule='all_failed',
    dag=dag)

t2.set_upstream(t1)
