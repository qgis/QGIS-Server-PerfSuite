#! /bin/bash

# env vars
PG_USER=root
PG_PASSWORD=root
PG_DB=data

ROOT=$PWD
if [ $# -eq 1 ]
then
    ROOT=$1
fi

# start servers
cd $ROOT
docker-compose up -d

# get ip for containers
DOCKER_IP_DATA=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qgisserver-perfsuite-data)

# wait for postgres to be ready
var=0
until PGPASSWORD=$PG_PASSWORD psql -h $DOCKER_IP_DATA -U $PG_USER -d $PG_DB -c '\q'
do
  >&2 echo "Data container is unavailable - sleeping ($var)"
  sleep 10

  var=`expr $var + 1`
  if [ "$var" -eq "10" ]
  then
    cd $ROOT
    docker-compose stop
    docker-compose rm -f
    exit 1
  fi
done

# access shared directory a 1st time
docker exec -it qgisserver-perfsuite-2.18 ls /data > /dev/null
docker exec -it qgisserver-perfsuite-3.10 ls /data > /dev/null
docker exec -it qgisserver-perfsuite-3.10-parallel-rendering ls /data > /dev/null
docker exec -it qgisserver-perfsuite-3.14 ls /data > /dev/null
docker exec -it qgisserver-perfsuite-3.14-parallel-rendering ls /data > /dev/null
docker exec -it qgisserver-perfsuite-master ls /data > /dev/null
docker exec -it qgisserver-perfsuite-master-parallel-rendering ls /data > /dev/null

# run graffiti
if [ ! -d "$ROOT/graffiti" ]
then
  git clone https://github.com/pblottiere/graffiti
  cd graffiti
  mkdir venv
  virtualenv -p /usr/bin/python3 ./venv
  . venv/bin/activate
  pip install -r requirements.txt
  deactivate
fi

cd $ROOT/graffiti
. venv/bin/activate
./graffiti.py --cfg $ROOT/scenarios.yml --style $ROOT/style.yml

# clear containers
cd $ROOT
docker-compose stop
docker-compose rm -f
