#!/bin/bash
# this script will be run inside the "data" container to prepare all data
# for the projects.
# Prerequisites:
# A shared permanent volume mounted as /data, where all SHPs and other
# generated files and project will be placed.

set -v

pushd .

# Fix cert permission
chown postgres /etc/ssl/private/ssl-cert-snakeoil.key

# Execute all commands inside the data_assets
cd /data_assets/

source /scripts/env-data.sh

source /scripts/setup-database.sh

# Run SQL commands
for sql in $(ls /data_assets/sql/*.sql | sort); do
    psql data -f "$sql";
done

# Download GPKG data if needed:
if [ ! -d "gpkg" ]; then
    wget --reject="index.html*" --no-parent --cut-dirs=2 -nH -r http://37.187.164.233/qgis-server-perfsuite/data/gpkg
    for d in qgs raster gpkg; do
        (ls $d/*.bz2 2> /dev/null && bzip2 -d $d/*.bz2 && rm -f $d/*.bz2) || true
    done
fi

if [ ! -d "/data/shp" ]; then
    mkdir /data/shp
fi

# Insert PG data and generate SHPs
for gpkg in $(ls /data_assets/gpkg/*.gpkg | sort); do

    TABLE_NAME=$(basename "$gpkg"|sed -e 's/\.gpkg//')

    # Check if PG table already exists
    if [[ `psql data -tAc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'ref' AND table_name = '{${TABLE_NAME}}');"` != 't' ]]; then
        echo "ogr2ogr creating '${TABLE_NAME}'..."
        ogr2ogr -f PostgreSQL "PG:dbname=data" gpkg/${TABLE_NAME}.gpkg -nln ref.{$TABLE_NAME}
    else
        echo "ogr2ogr skipping '${TABLE_NAME}': already exists."
    fi

    # Check is SHP already exists and generate them if not
    if [ ! -e "/data/shp/${TABLE_NAME}.shp" ]; then
        ogr2ogr -f 'ESRI Shapefile' "/data/shp/${TABLE_NAME}.shp" "gpkg/${TABLE_NAME}.gpkg"
    fi
done

# Last command
psql -d data --command "CREATE OR REPLACE VIEW public.adress_ban_view AS select * FROM ref.adress_ban;"

kill_postgres

# Make sure all generated/extracted assets are available in the /data shared volume
# SHPs are already generated in the /data shared volume.
cp -r /data_assets/gpkg /data
cp -r /data_assets/raster /data

popd