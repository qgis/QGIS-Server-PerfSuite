#! /bin/sh

BASEDIR=$(dirname "$0")

# Due to some issue with moc from Qt5.9 in docker, we have to proceed in 2
# steps (privileged mode is necessary to use moc for now:()
docker build ${BASEDIR} -t qgisserver-perfsuite/master-prepare
docker run --name perfsuite-master-build --rm --privileged -d -it qgisserver-perfsuite/master-prepare /bin/bash
docker exec perfsuite-master-build sh /root/qgis.sh
docker commit --change='CMD ["sh", "/root/cmd.sh"]' perfsuite-master-build qgisserver-perfsuite/master
docker stop perfsuite-master-build
sleep 5
docker rmi qgisserver-perfsuite/master-prepare
