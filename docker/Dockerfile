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
ARG AIRFLOW_VERSION=1.10
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_CODE=/usr/local/lib/python3.6/dist-packages/airflow
ARG AIRFLOW_PACKAGES=all
ARG SLUGIFY_USES_TEXT_UNIDECODE=yes

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV LANG en_US.UTF-8

RUN set -ex \
    && buildDeps=' \
        virtualenv \
        libmysqlclient-dev \
        libkrb5-dev \
        libsasl2-dev \
        mysql-client-core-5.7 \
        s3fs \
        redis-tools \
        openjdk-8-jre \
        git \
        locales \
        locales-all \
    ' \        
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
    && apt-get -fyqq install \
    && apt-get update -yqq \
    && ACCEPT_EULA=Y apt-get install -yqq \
        python3 \
        python3-dev \
        python3-pip \
        python3-gdbm \
    && locale-gen \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && python3 -m pip3 install --upgrade pip \
    && python3 -m pip3 install wheel \
    && pip install -U pip setuptools wheel \
    && pip install Cython \
    && pip install apache-airflow[${AIRFLOW_PACKAGES}]==$AIRFLOW_VERSION \
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

RUN chown -R airflow: ${AIRFLOW_HOME} \
    && chown -R airflow: /entrypoint.sh \
    && chmod 770 /entrypoint.sh

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["sh", "/entrypoint.sh"]