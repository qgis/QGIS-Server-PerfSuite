#!/bin/bash

export QGIS_SERVER_LOG_FILE=/var/log/qgisserver.log
export QGIS_SERVER_LOG_LEVEL=0

nginx -g 'daemon off;' &
xvfb-run /usr/bin/spawn-fcgi -n -U www-data -G www-data -s /var/run/qgisserver.sock /usr/local/bin/qgis_mapserv.fcgi
