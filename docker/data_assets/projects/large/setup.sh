#!/bin/bash
# Script to be run inside the data container to setup the large projects
# The /data/projects/large directory will be created and the script will
# exist immediately if that directory already exists.

if [ -d "/data/projects/large/gpkg" ]; then
    echo "Large projects already generated in /data/projects/large, delete that directory if you want to regenerate them."
    exit 0
else
    mkdir -p /data/projects/large/gpkg
    mkdir /data/projects/large/shp
    mkdir /data/projects/large/postgres
fi

apt update && apt install -y virtualenv python3-virtualenv
virtualenv -p /usr/bin/python3 venv
. venv/bin/activate
pip3 install -r /data_assets/projects/large/requirements.txt

/data_assets/projects/large/template.py --shp /data/projects/large/shp
/data_assets/projects/large/template.py --gpkg /data/projects/large/gpkg
/data_assets/projects/large/template.py --postgis /data/projects/large/postgres --pf
