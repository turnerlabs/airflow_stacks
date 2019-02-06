FROM ubuntu:16.04

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
ENV AIRFLOW_HOME=/usr/local/airflow

# Airflow
ARG AIRFLOW_VERSION=1.10.2
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_PACKAGES=all

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV SLUGIFY_USES_TEXT_UNIDECODE yes
ENV CFLAGS -I/usr/include/libffi/include
ENV AIRFLOW_HOME /usr/local/airflow

RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow

COPY ./script/entrypoint.sh /entrypoint.sh

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
    && pip uninstall -y redis \
    && pip install redis==2.10.6 \
    && apt-get autoremove -yqq --purge \
    && apt-get autoclean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

RUN chown -R airflow: ${AIRFLOW_HOME} \
    && chown -R airflow: /entrypoint.sh \
    && chmod 770 /entrypoint.sh

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}