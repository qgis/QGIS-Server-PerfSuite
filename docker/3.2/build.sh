#! /bin/sh

BASEDIR=$(dirname "$0")
docker build ${BASEDIR} -t qgisserver-perfsuite/3.2-prepare
docker run --name perfsuite-3.2-build --rm --privileged -d -it qgisserver-perfsuite/3.2-prepare /bin/bash
docker exec perfsuite-3.2-build sh /root/qgis.sh
docker commit --change='CMD ["sh", "/root/cmd.sh"]' perfsuite-3.2-build qgisserver-perfsuite/3.2
docker stop perfsuite-3.2-build
sleep 5
docker rmi qgisserver-perfsuite/3.2-prepare
