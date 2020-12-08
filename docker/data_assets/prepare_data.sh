#!/bin/bash
# this script will be run inside the "data" container to prepare all data
# for the projects.
# Prerequisites:
# A shared permanent volume mounted as /data, where all SHPs and other
# generated files and project will be placed.


pushd .

# Fix cert permission
chown postgres /etc/ssl/private/ssl-cert-snakeoil.key

# Execute all commands inside the data_assets
cd /data_assets/

source /scripts/env-data.sh

source /scripts/setup-database.sh


if [ ! -d "/data/shp" ]; then
    mkdir -p /data/shp
fi

# Run SQL commands
for sql in $(ls /data_assets/sql/*.sql | sort); do
    psql data -f "$sql";
done

# Make sure all generated/extracted assets are available in the /data shared volume
# SHPs are already generated in the /data shared volume.
cp -r /data_assets/gpkg /data
cp -r /data_assets/raster /data
cp -r /data_assets/projects /data

for d in qgs raster gpkg; do
    (ls /data/$d/*.bz2 2> /dev/null && bzip2 -d /data/$d/*.bz2 && rm -f /data/$d/*.bz2) || true
done


# Insert PG data and generate SHPs
for gpkg in $(ls /data/gpkg/*.gpkg | sort); do

    TABLE_NAME=$(basename "$gpkg"|sed -e 's/\.gpkg//')

    # Check if PG table already exists
    if [[ `psql data -tAc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'ref' AND table_name = '${TABLE_NAME}');"` != 't' ]]; then
        echo "ogr2ogr creating PG '${TABLE_NAME}'..."
        ogr2ogr -f PostgreSQL "PG:dbname=data" /data/gpkg/${TABLE_NAME}.gpkg -nln ref.${TABLE_NAME}
    else
        echo "ogr2ogr skipping PG '${TABLE_NAME}': already exists."
    fi

    # Check is SHP already exists and generate them if not
    if [ ! -e "/data/shp/${TABLE_NAME}.shp" ]; then
        ogr2ogr -f 'ESRI Shapefile' "/data/shp/${TABLE_NAME}.shp" "/data/gpkg/${TABLE_NAME}.gpkg"
    fi
done

# Last SQL command
psql -d data --command "CREATE OR REPLACE VIEW public.adress_ban_view AS select * FROM ref.adress_ban;"


# Generate the large projects
source /data_assets/projects/large/setup.sh


kill_postgres

popd
