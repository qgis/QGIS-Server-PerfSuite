#!/bin/bash
# Run 5 times
for i in {1..5}; do /env.sh /precision_time.sh /qgis_build/output/bin/qgis_mapserv.fcgi; done 2>&1 1>/dev/null|grep -v Loading|sort

