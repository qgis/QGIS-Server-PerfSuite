FROM oslandia/postgres-postgis

RUN apt-get update && apt-get install -y \
  wget

# Download data
WORKDIR /data
RUN wget http://37.187.164.233/qgis-server-perfsuite/dump_open_data.backup

# Configure postgres
RUN pg_createcluster 10 main --start

USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER root WITH SUPERUSER PASSWORD 'root';" && \
    createdb -O root data && \
    psql --command "CREATE EXTENSION postgis;" -d data && \
    pg_restore -d data /data/dump_open_data.backup || true

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/10/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf

EXPOSE 5432
CMD ["/usr/lib/postgresql/10/bin/postgres", "-D", "/var/lib/postgresql/10/main", "-c", "config_file=/etc/postgresql/10/main/postgresql.conf"]
