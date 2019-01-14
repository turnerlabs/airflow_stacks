# How do I use this.

This is a dockerized version of the airflow stack.

This code was taken from <https://github.com/puckel/docker-airflow> and modified to follow the patterns that I'm using in AWS.

## Here's how to get up and running with this on a Mac

1. Install Docker for Mac. https://docs.docker.com/docker-for-mac/install/

2. Modify Docker for Mac settings to work more optimally with airflow.
    * Open up the preferences menu item on Docker for the Mac and modify each tab to look similar to this.

![General](../images/docker1.png?raw=true)

![File Sharing](../images/docker2.png?raw=true)

![Disk](../images/docker3.png?raw=true)

![Advanced](../images/docker4.png?raw=true)

![Proxies](../images/docker5.png?raw=true)

![Daemon](../images/docker6.png?raw=true)

![Kubernetes](../images/docker7.png?raw=true)


## Building, Starting and Stopping Docker.

Once Docker for Mac is up and running you need to do the following 2 items to start using it:

** assuming you have cloned this repo and are cd'd to this directory

--- Build the airflow docker image

`docker build --rm -t turnerlabs/docker-airflow .`

--- Run Docker Compose up to start up the airflow stack(webserver, scheduler, worker, redis, mysql)

`docker-compose --verbose -f docker-compose.yml up -d`

--- To take everything down, use:

`docker-compose --verbose -f docker-compose.yml down`

## Here's a typical "I'm creating a helloworld dag" work flow

1. Start out by verifying that everything is running.  Type `docker ps` and your screen should look similar to this:
![dockerps](../images/docker8.png?raw=true)

2. Change to the airflow directory using `cd airflow`
      * This is your AIRFLOW_HOME.  The webserver, scheduler, and worker containers all have mounted this directory so they will react to any changes you make here.

3. Create a hello world dag to see if things are working.
      * Copy and paste the following code into helloworld.py in the dags directory.

```python
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta


default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.datetime.now() - datetime.timedelta(minutes=15),
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

dag = DAG('helloworld', default_args=default_args, schedule_interval='0/1 * * * *',)

# t1, t2 and t3 are examples of tasks created by instantiating operators
t1 = BashOperator(
    task_id='print_date',
    bash_command='date',
    dag=dag)

t2 = BashOperator(
    task_id='sleep',
    bash_command='sleep 5',
    retries=3,
    dag=dag)

templated_command = """
    {% for i in range(20) %}
        echo "{{ ds }}"
        echo "{{ macros.ds_add(ds, 7)}}"
        echo "{{ params.my_param }}"
    {% endfor %}
"""

t3 = BashOperator(
    task_id='templated',
    bash_command=templated_command,
    params={'my_param': 'Parameter I passed in'},
    dag=dag)

t2.set_upstream(t1)
t3.set_upstream(t1)
```

4. Navigate to http://localhost:8080 to the airflow website.
      * The scheduler polls the dag directory every 60 seconds so it may take a minute for changes to show up in the ui.

5. Turn on the helloworld dag once you see the on / off toggle button.

6. Once the DAG starts you can monitor airflow's services logs and the tasks logs in the following way:
      * WebServer - `docker logs -f docker_webserver_1`
      * Scheduler - `docker logs -f docker_scheduler_1`
      * Worker - `docker logs -f docker_worker_1`
      * Task output - `cd airflow/logs/helloworld` - although I suggest using the UI for this.

7. You should be able to iterate here and see any code changes you make get applied within a minute or less.

### TODO's
- Add the ability to load requirements, variables and connections.
    - I plan on this being a quick `docker stop docker_webserver_1 docker_scheduler_1 docker_worker_1`, `docker start docker_webserver_1 docker_scheduler_1 docker_worker_1` to load these files but need to test it out first.
