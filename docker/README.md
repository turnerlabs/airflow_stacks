# What is this

This is a dockerized version of the airflow stack.  Needs much more testing and verifying.

This code was taken from <https://github.com/puckel/docker-airflow> and re-structured to use snowflake and rabbit mq instead.

Here's the order of commands to get this up and running:

--- Build the image

`docker build --rm -t turnerlabs/docker-airflow .`

--- Docker Compose up using the web server, scheduler, worker, flower, redis, and mysql

`docker-compose --verbose -f docker-compose.yml up -d`

--- To shut this down, use:

`docker-compose --verbose -f docker-compose.yml down`