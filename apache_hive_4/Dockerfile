FROM apache/hive:4.0.0

USER root

# Cài locale UTF-8
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Tải driver PostgreSQL JDBC và copy vào lib Hive
ADD https://repo1.maven.org/maven2/org/postgresql/postgresql/42.6.0/postgresql-42.6.0.jar /opt/hive/lib/

# Set quyền cho user hive
RUN chown hive:hive /opt/hive/lib/postgresql-42.6.0.jar

USER hive
