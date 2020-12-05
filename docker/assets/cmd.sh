#!/bin/bash
# Script that can be run inside the docker to run QGIS Server FCGI on port 5555

/usr/bin/xvfb-run \
    -a \
    -s "-ac -screen 0 1280x1024x16 +extension GLX +render -noreset" \
    /usr/bin/spawn-fcgi \
        -d /usr/lib/qgis/ \
        -n \
        -p 5555 \
        -- \
        /usr/bin/qgis_mapserv.fcgi