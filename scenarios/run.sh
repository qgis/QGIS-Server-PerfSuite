#! /bin/bash

# env vars
PG_USER=root
PG_PASSWORD=root
PG_DB=data

# start servers
cd ~/scenarios
docker-compose up -d

# get ip for containers
DOCKER_IP_2_14=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qgisserver-perfsuite-2.14)
DOCKER_IP_2_18=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qgisserver-perfsuite-2.18)
DOCKER_IP_3_0=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qgisserver-perfsuite-3.0)
DOCKER_IP_3_0_PARALLEL_RENDERING=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qgisserver-perfsuite-3.0-parallel-rendering)
DOCKER_IP_MASTER=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qgisserver-perfsuite-master)
DOCKER_IP_MASTER_PARALLEL_RENDERING=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qgisserver-perfsuite-master-parallel-rendering)
DOCKER_IP_DATA=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qgisserver-perfsuite-data)

# wait for postgres to be ready
until PGPASSWORD=$PG_PASSWORD psql -h $DOCKER_IP_DATA -U $PG_USER -d $PG_DB -c '\q'
do
  >&2 echo "Data container is unavailable - sleeping"
  sleep 10
done

# access shared directory a 1st time
docker exec -it qgisserver-perfsuite-2.14 ls /data > /dev/null
docker exec -it qgisserver-perfsuite-2.18 ls /data > /dev/null
docker exec -it qgisserver-perfsuite-3.0 ls /data > /dev/null
docker exec -it qgisserver-perfsuite-3.0-parallel-rendering ls /data > /dev/null
docker exec -it qgisserver-perfsuite-master ls /data > /dev/null
docker exec -it qgisserver-perfsuite-master-parallel-rendering ls /data > /dev/null

# prepare scenario configuration file with ips of containers
cp scenarios.sample.yml scenarios.yml
sed -i "s/{{ URL_2_14 }}/$DOCKER_IP_2_14/g" scenarios.yml
sed -i "s/{{ URL_2_18 }}/$DOCKER_IP_2_18/g" scenarios.yml
sed -i "s/{{ URL_3_0 }}/$DOCKER_IP_3_0/g" scenarios.yml
sed -i "s/{{ URL_3_0_PARALLEL_RENDERING }}/$DOCKER_IP_3_0_PARALLEL_RENDERING/g" scenarios.yml
sed -i "s/{{ URL_MASTER }}/$DOCKER_IP_MASTER/g" scenarios.yml
sed -i "s/{{ URL_MASTER_PARALLEL_RENDERING }}/$DOCKER_IP_MASTER_PARALLEL_RENDERING/g" scenarios.yml

# run graffiti
cd ~/graffiti
. venv/bin/activate
./graffiti.py --cfg ~/scenarios/scenarios.yml

# clear containers
cd ~/scenarios
docker-compose stop
docker-compose rm -f
