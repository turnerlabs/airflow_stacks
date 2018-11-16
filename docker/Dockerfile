FROM ubuntu:16.04

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.1rc2
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_PACKAGES=all

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV SLUGIFY_USES_TEXT_UNIDECODE yes

RUN set -ex \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq \
        unattended-upgrades \
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
        git \
        build-essential \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
        locales-all \
    && locale-gen \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1 \
    && echo 'export AIRFLOW_HOME=/usr/local/airflow' >> /usr/local/.bash_profile \
    && pip3 install -U pip setuptools wheel \
    && pip install apache-airflow[${AIRFLOW_PACKAGES}]==$AIRFLOW_VERSION \
    && sed -i '1 i\server time.google.com prefer iburst'  /etc/chrony/chrony.conf \
    && apt-get autoremove -yqq --purge \
    && apt-get autoclean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh

RUN chown -R airflow: ${AIRFLOW_HOME} \
    && chown -R airflow: /entrypoint.sh \
    && chmod 770 /entrypoint.sh

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}