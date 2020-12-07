#!/bin/bash
# Script to be run inside the data container to setup the large projects
# The /data/large_projects directory will be created and the script will
# exist immediately if that directory already exists.

if [ -d "/data/large_projects" ]; then
    echo "Large projects already generated in /data/large_projects, delete that directory if you want to regenerate them."
    exit 0
else
    mkdir -p /data/large_projects/gpkg
    mkdir /data/large_projects/shp
    mkdir /data/large_projects/postgres
fi

apt update && apt install -y python3-geopandas python3-sqlalchemy
pip3 install pgtoolkit

/data_assets/large_projects/template.py --shp /data/large_projects/shp
/data_assets/large_projects/template.py --gpkg /data/large_projects/gpkg
/data_assets/large_projects/template.py --postgres /data/large_projects/postgres
