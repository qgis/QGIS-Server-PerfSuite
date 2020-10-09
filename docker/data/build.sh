#! /bin/sh

BASEDIR=$(dirname "$0")
NAME="qgisserver-perfsuite/data"

rm -rf data/data/sqlite
rm -rf data/data/shp
rm -f data/data/gpkg/*.gpkg
rm -f data/data/raster/*.tif
rm -f data/data/raster/*.ovr

docker rmi $NAME
docker build ${BASEDIR} -t $NAME

docker create -ti --name data $NAME bash
docker cp data:/data/data/shp $(pwd)/data/data/
docker cp data:/data/data/sqlite $(pwd)/data/data/

docker cp data:/data/data/gpkg/adress_ban.gpkg $(pwd)/data/data/gpkg/
docker cp data:/data/data/gpkg/hydro_lake.gpkg $(pwd)/data/data/gpkg/
docker cp data:/data/data/gpkg/hydro_segment.gpkg $(pwd)/data/data/gpkg/
docker cp data:/data/data/gpkg/hydro_cours_eau_geoml93.gpkg $(pwd)/data/data/gpkg/
docker cp data:/data/data/gpkg/hydro_course_geomsimple.gpkg $(pwd)/data/data/gpkg/
docker cp data:/data/data/gpkg/landuse_corine_lc_2006.gpkg $(pwd)/data/data/gpkg/
docker cp data:/data/data/gpkg/parcelles.gpkg $(pwd)/data/data/gpkg/
docker cp data:/data/data/gpkg/vw_clc2006.gpkg $(pwd)/data/data/gpkg/

docker cp data:/data/data/raster/eu_dem_v11_hillshade.tif $(pwd)/data/data/raster/
docker cp data:/data/data/raster/eu_dem_v11_hillshade.tif.ovr $(pwd)/data/data/raster/
docker cp data:/data/data/raster/eu_dem_v11.tif $(pwd)/data/data/raster/
docker cp data:/data/data/raster/eu_dem_v11.tif.ovr $(pwd)/data/data/raster/

docker rm -f data
