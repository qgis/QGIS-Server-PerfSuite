FROM oslandia/postgres-postgis

RUN apt-get update && apt-get install -y \
  wget \
  gdal-bin

# Download data
WORKDIR /data
RUN wget --reject="index.html*" --no-parent --cut-dirs=2 -nH -r http://37.187.164.233/qgis-server-perfsuite/data/gpkg

# Configure postgres
RUN pg_createcluster 10 main --start

RUN echo "pg_ctl_options = '-t 600'" > /etc/postgresql/10/main/pg_ctl.conf

USER postgres

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/10/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf
RUN echo "shared_preload_libraries = 'pg_stat_statements'" >> /etc/postgresql/10/main/postgresql.conf

RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER root WITH SUPERUSER PASSWORD 'root';" && \
    createdb -O root data && \
    psql --command "CREATE EXTENSION postgis;" -d data && \
    psql --command "CREATE EXTENSION pg_stat_statements;" -d data && \
    psql --command "CREATE SCHEMA ref;" -d data && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/adress_ban.gpkg -nln ref.adress_ban && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_bassin.gpkg -nln ref.hydro_bassin && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_cours_eau_geoml93.gpkg -nln ref.hydro_cours_eau.geoml93 && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_cours_eau_geomroute.gpkg -nln ref.hydro_cours_eau.geomroute && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_cours_eau_geomsimple.gpkg -nln ref.hydro_cours_eau.geomsimple && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_course_geoml93.gpkg -nln ref.hydro_course.geoml93 && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_course_geomsimple.gpkg -nln ref.hydro_course.geomsimple && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_lake.gpkg -nln ref.hydro_lake && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_segment.gpkg -nln ref.hydro_segment && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/landuse_corine_lc_2006.gpkg -nln ref.landuse_corine_lc_2006 && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/vw_clc2006.gpkg -nln ref.vw_clc2006 && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/parcelles.gpkg -nln ref.parcelles && \
    psql -d data --command "CREATE VIEW public.adress_ban_view AS select * FROM ref.adress_ban;"

EXPOSE 5432
CMD ["/usr/lib/postgresql/10/bin/postgres", "-D", "/var/lib/postgresql/10/main", "-c", "config_file=/etc/postgresql/10/main/postgresql.conf"]
