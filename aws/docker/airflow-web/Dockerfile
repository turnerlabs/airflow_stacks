FROM ubuntu:16.04

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.1
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_PACKAGES=azure_blob_storage,azure_data_lake,celery,crypto,elasticsearch,hdfs,hive,jdbc,kerberos,mssql,mysql,oracle,password,postgres,redis,s3,slack,mongo,snowflake,ssh

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV SLUGIFY_USES_TEXT_UNIDECODE yes
ENV CFLAGS -I/usr/include/libffi/include

RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow

COPY ./script/entrypoint.sh /entrypoint.sh

COPY ./config/airflow.conf /usr/lib/tmpfiles.d/airflow.conf
COPY ./config/airflow.sysconfig /etc/profile.d/airflow.sh
COPY ./systemd/airflow-scheduler.service /lib/systemd/system/airflow-scheduler.service

COPY ./config/logrotate.conf /usr/local/airflow/logrotate.conf
COPY ./config/awslogs.conf /usr/local/airflow/awslogs.conf
COPY ./cron/crontab /usr/local/airflow/crontab
COPY ./scripts/pip_mod_install.sh /usr/local/airflow/pip_mod_install.sh
COPY ./scripts/airflow_vars_install.sh /usr/local/airflow/airflow_vars_install.sh
COPY ./scripts/dags_install.sh /usr/local/airflow/dags_install.sh

RUN mkdir /run/airflow \
    && chown airflow:airflow /run/airflow \
    && mkdir /usr/local/airflow/dags \
    && chown airflow:airflow /usr/local/airflow/dags \
    && mkdir /usr/local/airflow/data \
    && chown airflow:airflow /usr/local/airflow/data \
    && mkdir /usr/local/airflow/logs \
    && chown airflow:airflow /usr/local/airflow/logs \
    && mkdir /usr/local/airflow/plugins \
    && chown airflow:airflow /usr/local/airflow/plugins \
    && mkdir /usr/local/airflow/requirements \
    && chown airflow:airflow /usr/local/airflow/requirements \
    && mkdir /usr/local/airflow/variables \
    && chown airflow:airflow /usr/local/airflow/variables \
    && chown -R airflow:airflow ${AIRFLOW_HOME} \
    && chown -R airflow:airflow /entrypoint.sh \
    && chown -R airflow:airflow /usr/local/airflow/logrotate.conf \
    && chown -R airflow:airflow /usr/local/airflow/awslogs.conf \
    && chown -R airflow:airflow /usr/local/airflow/crontab \
    && chown -R airflow:airflow /usr/local/airflow/pip_mod_install.sh \
    && chown -R airflow:airflow /usr/local/airflow/airflow_vars_install.sh \
    && chown -R airflow:airflow /usr/local/airflow/dags_install.sh \
    && chmod 770 /entrypoint.sh \
    && chmod 600 /usr/lib/tmpfiles.d/airflow.conf \
    && chmod 600 /etc/profile.d/airflow.sh \
    && chmod 600 /lib/systemd/system/airflow-scheduler.service \
    && chmod 600 /usr/local/airflow/logrotate.conf \
    && chmod 600 /usr/local/airflow/awslogs.conf \
    && chmod 700 /usr/local/airflow/crontab \
    && chmod 700 /usr/local/airflow/pip_mod_install.sh \
    && chmod 700 /usr/local/airflow/airflow_vars_install.sh \
    && chmod 700 /usr/local/airflow/dags_install.sh

RUN set -ex \
    && apt-get update -yqq --fix-missing \
    && apt-get -y install -yqq apt-transport-https curl gnupg \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update -yqq \
    && ACCEPT_EULA=Y apt-get -y install msodbcsql17 mssql-tools \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /usr/local/airflow/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /usr/local/airflow/.bashrc \    
    && apt-get install -yqq --no-install-recommends \
        unixodbc \
        unixodbc-dev \
        chrony \
        jq \
        python3-pip \
        libmysqlclient-dev \
        python3-dev \
        python3 \
        libkrb5-dev \
        libsasl2-dev \
        mysql-client-core-5.7 \
        python3-gdbm \
        redis-tools \
        openjdk-8-jre \
        cron \
        git \
        build-essential \
        apt-utils \
        rsync \
        netcat \
        locales \
        language-pack-en-base \
        language-pack-en \
    && locale-gen \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1 \
    && echo 'export AIRFLOW_HOME=/usr/local/airflow' >> /usr/local/airflow/.bash_profile \
    && pip3 install -U pip setuptools wheel \
    && pip install apache-airflow[${AIRFLOW_PACKAGES}]==$AIRFLOW_VERSION \
    && pip install botocore==1.12.58 \
    && pip install awscli==1.16.68 \    
    && pip uninstall -y redis \
    && pip install redis==2.10.6 \
    && sed -i '1 i\server 169.254.169.123 prefer iburst'  /etc/chrony/chrony.conf \
    && curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O \
    && python3 ./awslogs-agent-setup.py -n -r us-east-1 -c /usr/local/airflow/awslogs.conf \    
    && crontab -u airflow /usr/local/airflow/crontab \
    && apt-get purge --auto-remove -yqq  \
        unixodbc-dev \
        libkrb5-dev \ 
        libsasl2-dev \
        build-essential \
        apt-utils \        
        git \
    && apt-get autoremove -yqq --purge \
    && apt-get autoclean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}