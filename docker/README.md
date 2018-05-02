# What is this

This is a dockerized version of the airflow stack running on instances in AWS.

This code was taken from <https://github.com/puckel/docker-airflow> and re-structured to use snowflake and rabbit mq instead.

It is definitely a work in progress and snowflake is still a wip.

Here's the order of commands to get this up and running:

--- Build the image

`docker build --rm -t turnerlabs/docker-airflow .`

--- Docker Compose up either the version running just the web server and mysql

`docker-compose --verbose -f docker-compose-LocalExecutor.yml up -d`

--- or the one using the web server, scheduler, worker, flower, and mysql

`docker-compose --verbose -f docker-compose-CeleryExecutor.yml up -d`

--- To shut this down, try either:

`docker-compose --verbose -f docker-compose-LocalExecutor.yml down`

--- Or

`docker-compose --verbose -f docker-compose-CeleryExecutor.yml down`