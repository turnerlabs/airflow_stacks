# VERSION 1.9.0-2
# AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow .
# SOURCE: https://github.com/puckel/docker-airflow

FROM ubuntu:16.04

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.9.0
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_CODE=/usr/local/lib/python3.6/dist-packages/airflow

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV LANG en_US.UTF-8

COPY odbc/msodbcsql17_17.1.0.1-1_amd64.deb ${AIRFLOW_HOME}/msodbcsql17_17.1.0.1-1_amd64.deb

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        git \
        freetds-dev \
        unixodbc-dev \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        apt-utils \
        software-properties-common \
        python-setuptools \
        gcc \
        g++ \
        curl \
        rsync \
        netcat \
        locales \
        libmysqlclient-dev \
        libmysqld-dev \
        mysql-client-core-5.7 \
        unixodbc \
        freetds-bin \
        tdsodbc \
        libcurl3 \
        default-jre \
        libc6-i386 \
        apt-transport-https \
        python3-gdbm \
    && add-apt-repository -y ppa:jonathonf/python-3.6 \
    && ACCEPT_EULA=Y dpkg -i ${AIRFLOW_HOME}/msodbcsql17_17.1.0.1-1_amd64.deb \
    && apt-get -fyqq install \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
    && apt-get update -yqq \
    && ACCEPT_EULA=Y apt-get install -yqq \
        python3.6 \
        python3.6-dev \
        python3-pip \
        mssql-tools \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 3 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && python3 -m pip install pip --upgrade \
    && python3 -m pip install wheel \
    && pip install -U pip setuptools wheel \
    && pip install Cython \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install html5lib \ 
    && pip install 'boto3<1.7' \
    && pip install markupsafe \
    && pip install flask_bcrypt \
    && pip install snowflake-connector-python \
    && pip install celery \
    && pip install 'zope.deprecation<5.0' \
    && pip install cryptography \
    && pip install paramiko \
    && pip install fernet \
    && pip install jaydebeapi \
    && pip install pyodbc \
    && pip install apache-airflow[all]==$AIRFLOW_VERSION \
    && pip install 'sqlalchemy<1.2' \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

COPY snowflake/models.py ${AIRFLOW_CODE}/models.py
COPY snowflake/hooks__init__.py ${AIRFLOW_CODE}/contrib/hooks/__init__.py
COPY snowflake/snowflake_hook.py ${AIRFLOW_CODE}/contrib/hooks/snowflake_hook.py
COPY snowflake/operators__init__.py ${AIRFLOW_CODE}/contrib/operators/__init__.py
COPY snowflake/snowflake_operator.py ${AIRFLOW_CODE}/contrib/operators/snowflake_operator.py

RUN chmod 664 ${AIRFLOW_CODE}/models.py \
    && chmod 664 ${AIRFLOW_CODE}/contrib/hooks/__init__.py \
    && chmod 664 ${AIRFLOW_CODE}/contrib/hooks/snowflake_hook.py \
    && chmod 664 ${AIRFLOW_CODE}/contrib/operators/__init__.py \
    && chmod 664 ${AIRFLOW_CODE}/contrib/operators/snowflake_operator.py \
    && mkdir ${AIRFLOW_HOME}/drivers \
    && chmod 664 ${AIRFLOW_CODE}/hooks/jdbc_hook.py \
    && chown -R airflow: ${AIRFLOW_HOME} \
    && chown -R airflow: /entrypoint.sh \
    && chmod 770 /entrypoint.sh

COPY jdbc/snowflake-jdbc-3.5.4.jar ${AIRFLOW_HOME}/drivers/snowflake-jdbc-3.5.4.jar
COPY jdbc/jdbc_hook.py ${AIRFLOW_CODE}/hooks/jdbc_hook.py

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["sh", "/entrypoint.sh"]
