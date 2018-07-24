#! /bin/bash

echo "Remove docker image for master"
echo "------------------------------"
docker rmi qgisserver-perfsuite/master

echo "Build new docker image for master"
echo "---------------------------------"
cd docker/master && sh build.sh && cd -

echo "Run graffiti"
echo "------------"
cd scenarios && sh run.sh && cd -
