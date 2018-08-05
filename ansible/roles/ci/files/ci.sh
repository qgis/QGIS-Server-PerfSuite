#! /bin/bash
GRAFFITI=/tmp/graffiti
DATE=$(date +"%Y_%m_%d_%H_%M")

echo "Remove docker image for master"
echo "------------------------------"
docker rmi qgisserver-perfsuite/master

echo "Build new docker image for master"
echo "---------------------------------"
cd docker/master && sh build.sh && cd -

echo "Run graffiti"
echo "------------"
cd scenarios && sh run.sh && cd -
rm -rf $GRAFFITI
cd scenarios && sh run.sh && cd -
if [ -d $GRAFFITI ]
then
  scp -r $GRAFFITI qgis-test:/var/www/qgisdata/QGIS-tests/perf_test/graffiti/$DATE
fi
