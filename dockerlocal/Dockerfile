FROM python:3.5.6-alpine3.8

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.1
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_PACKAGES=all

# Define en_US.
ENV SLUGIFY_USES_TEXT_UNIDECODE yes
ENV CFLAGS -I/usr/include/libffi/include

RUN set -ex \
    && apk update \
    && apk upgrade \
    && apk add \
        mariadb-dev \
        freetds-dev \
        krb5-dev \
        cyrus-sasl-dev \
        py3-cffi \
        libffi-dev \
        libxslt \
        libxslt-dev \
        libxml2 \
        libxml2-dev  \
        linux-headers \
        postgresql-libs \
        build-base \
        python3-dev \
        subversion \
        bash \
        libsasl \
        krb5 \
        chrony \
        jq \
        git \
        curl \
        rsync \
    && apk add --virtual .build-deps gcc musl-dev postgresql-dev \
    && apk --no-cache add ca-certificates wget \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-bin-2.28-r0.apk \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-i18n-2.28-r0.apk \
    && apk add glibc-bin-2.28-r0.apk glibc-i18n-2.28-r0.apk glibc-2.28-r0.apk \
    && addgroup -S airflow \
    && adduser -s /bin/bash -h ${AIRFLOW_HOME} -S airflow -G airflow \
    && echo 'export AIRFLOW_HOME=/usr/local/airflow' >> /usr/local/.bash_profile \
    && pip3 install -U pip setuptools wheel cython \
    && pip install apache-airflow[${AIRFLOW_PACKAGES}]==$AIRFLOW_VERSION \
    && pip uninstall -y redis \
    && pip install redis==2.10.6 \
    && sed -i '1 i\server time.google.com prefer iburst'  /etc/chrony/chrony.conf \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && /usr/glibc-compat/bin/locale -a

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

COPY script/entrypoint.sh /entrypoint.sh

RUN chown -R airflow: ${AIRFLOW_HOME} \
    && chown -R airflow: /entrypoint.sh \
    && chmod 770 /entrypoint.sh

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}