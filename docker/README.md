# How do I use this.

This is a dockerized version of the airflow stack.

This code was taken from <https://github.com/puckel/docker-airflow> and modified to follow the patterns that I'm using in AWS.

Here's how to get up and running with this on a Mac.

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

Here's the order of commands to get this up and running:

--- Build the image

`docker build --rm -t turnerlabs/docker-airflow .`

--- Docker Compose up using the web server, scheduler, worker, flower, redis, and mysql

`docker-compose --verbose -f docker-compose.yml up -d`

--- To shut this down, use:

`docker-compose --verbose -f docker-compose.yml down`