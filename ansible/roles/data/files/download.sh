#! /bin/bash

URL=http://37.187.164.233/qgis-server-perfsuite/

mkdir -p data

wget $URL/eu_dem_v11.tif -P ./data
wget $URL/eu_dem_v11.tif.ovr -P ./data
wget $URL/opendata_disclaimer.md -P ./data
wget $URL/data_perf.qgs -P ./data
wget $URL/data_perf_view.qgs -P ./data
wget $URL/data_perf_view_trust.qgs -P ./data
