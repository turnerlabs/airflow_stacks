--- Build the airflow docker image

`docker build --rm -t turnerlabs/airflow-wrkr .`

--- Run Docker Compose up to start up the airflow webserver

`docker-compose --verbose -f docker-compose.yml up -d`

--- To take everything down, use:

`docker-compose --verbose -f docker-compose.yml down`
