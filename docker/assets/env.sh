#!/bin/bash
# Run QGIS Server or another command from the container

COMMAND="$@"

if [ "${COMMAND}" == "" ]; then
  COMMAND="/qgis_build/output/bin/qgis_mapserver"
fi
export LD_LIBRARY_PATH=/qgis_build/output/lib:$LD_LIBRARY_PATH
export QGIS_SERVER_IGNORE_BAD_LAYERS=${QGIS_SERVER_IGNORE_BAD_LAYERS:-true}
export QGIS_SERVER_LOG_STDERR=${QGIS_SERVER_LOG_STDERR:-true}
export QGIS_PREFIX_PATH=/qgis_build/output
export QGIS_AUTH_DB_DIR_PATH=${QGIS_AUTH_DB_DIR_PATH:-/tmp}
export PYTHONPATH=/qgis_build/output/share/qgis/python/:/qgis_build/output/share/qgis/python/plugins:/qgis_build/output/lib/python3/dist-packages/qgis:/qgis_build/output/share/qgis/python/qgis
cd /qgis_build/output/
${COMMAND}
