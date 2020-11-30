FROM oslandia/postgres-postgis

RUN apt-get update && apt-get install -y \
  wget \
  gdal-bin \
  python3 \
  virtualenv \
  bzip2

# Download data
WORKDIR /data
COPY data .
RUN chown postgres:postgres /data/qgs/template

WORKDIR /data/data/gpkg
RUN bzip2 -d *

WORKDIR /data/data/raster
RUN bzip2 -d *

WORKDIR /data/data/

# extract shapefile from gpkg
RUN mkdir -p shp && \
    ogr2ogr -f 'ESRI Shapefile' shp/adress_ban.shp gpkg/adress_ban.gpkg && \
    ogr2ogr -f 'ESRI Shapefile' shp/hydro_cours_eau_geoml93.shp gpkg/hydro_cours_eau_geoml93.gpkg && \
    ogr2ogr -f 'ESRI Shapefile' shp/hydro_course_geomsimple.shp gpkg/hydro_course_geomsimple.gpkg && \
    ogr2ogr -f 'ESRI Shapefile' shp/hydro_lake.shp gpkg/hydro_lake.gpkg && \
    ogr2ogr -f 'ESRI Shapefile' shp/hydro_segment.shp gpkg/hydro_segment.gpkg && \
    ogr2ogr -f 'ESRI Shapefile' shp/landuse_corine_lc_2006.shp gpkg/landuse_corine_lc_2006.gpkg && \
    ogr2ogr -f 'ESRI Shapefile' shp/vw_clc2006.shp gpkg/vw_clc2006.gpkg && \
    ogr2ogr -f 'ESRI Shapefile' shp/parcelles.shp gpkg/parcelles.gpkg

# store data in spatialite
RUN mkdir -p sqlite && \
    ogr2ogr -f SQLite -dsco SPATIALITE=yes sqlite/data.sqlite gpkg/adress_ban.gpkg -nln adress_ban && \
    ogr2ogr -update -f SQLite -dsco SPATIALITE=yes sqlite/data.sqlite gpkg/hydro_cours_eau_geoml93.gpkg -nln hydro_cours_eau_geoml93 && \
    ogr2ogr -update -f SQLite -dsco SPATIALITE=yes sqlite/data.sqlite gpkg/hydro_course_geomsimple.gpkg -nln hydro_course_geomsimple && \
    ogr2ogr -update -f SQLite -dsco SPATIALITE=yes sqlite/data.sqlite gpkg/hydro_lake.gpkg -nln hydro_lake && \
    ogr2ogr -update -f SQLite -dsco SPATIALITE=yes sqlite/data.sqlite gpkg/hydro_segment.gpkg -nln hydro_segment && \
    ogr2ogr -update -f SQLite -dsco SPATIALITE=yes sqlite/data.sqlite gpkg/landuse_corine_lc_2006.gpkg -nln landuse_corine_lc_2006 && \
    ogr2ogr -update -f SQLite -dsco SPATIALITE=yes sqlite/data.sqlite gpkg/vw_clc2006.gpkg -nln vw_clc2006 && \
    ogr2ogr -update -f SQLite -dsco SPATIALITE=yes sqlite/data.sqlite gpkg/parcelles.gpkg -nln parcelles

# Configure postgres
RUN pg_createcluster 10 main --start

RUN echo "pg_ctl_options = '-t 600'" > /etc/postgresql/10/main/pg_ctl.conf

USER postgres

# prepare the project generator env
WORKDIR /data/qgs/template
RUN virtualenv -p /usr/bin/python3 venv && \
    . venv/bin/activate && \
    pip install -r requirements.txt

# generate a large project based on shapefiles from the template
RUN . venv/bin/activate && \
    mkdir shp && \
    ./template.py --shp shp

# generate a large project based on geopackages from the template
RUN . venv/bin/activate && \
    mkdir gpkg && \
    ./template.py --gpkg gpkg

WORKDIR /data/data/
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/10/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf
RUN echo "shared_preload_libraries = 'pg_stat_statements'" >> /etc/postgresql/10/main/postgresql.conf

# store gpkg into postgis
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER root WITH SUPERUSER PASSWORD 'root';" && \
    createdb -O root data && \
    psql --command "CREATE EXTENSION postgis;" -d data && \
    psql --command "CREATE EXTENSION pg_stat_statements;" -d data && \
    psql --command "CREATE SCHEMA ref;" -d data && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/adress_ban.gpkg -nln ref.adress_ban && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_cours_eau_geoml93.gpkg -nln ref.hydro_cours_eau.geoml93 && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_course_geomsimple.gpkg -nln ref.hydro_course.geomsimple && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_lake.gpkg -nln ref.hydro_lake && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/hydro_segment.gpkg -nln ref.hydro_segment && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/landuse_corine_lc_2006.gpkg -nln ref.landuse_corine_lc_2006 && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/vw_clc2006.gpkg -nln ref.vw_clc2006 && \
    ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/parcelles.gpkg -nln ref.parcelles && \
    psql -d data --command "CREATE VIEW public.adress_ban_view AS select * FROM ref.adress_ban;" && \
    cd ../qgs/template && \
    mkdir -p postgis && \
    . venv/bin/activate && \
    ./template.py --postgis postgis --pf

EXPOSE 5432
CMD ["/usr/lib/postgresql/10/bin/postgres", "-D", "/var/lib/postgresql/10/main", "-c", "config_file=/etc/postgresql/10/main/postgresql.conf"]
