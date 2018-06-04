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
DOCKER_IP_DATA=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qgisserver-perfsuite-data)

# wait for postgres to be ready
until PGPASSWORD=$PG_PASSWORD psql -h $DOCKER_IP_DATA -U $PG_USER -d $PG_DB -c '\q'
do
  >&2 echo "Data container is unavailable - sleeping"
  sleep 1
done

# access shared directory a 1st time
docker exec -it qgisserver-perfsuite-2.14 ls /data > /dev/null
docker exec -it qgisserver-perfsuite-2.18 ls /data > /dev/null

# prepare scenario configuration file with ips of containers
cp scenarios.sample.yml scenarios.yml
sed -i "s/{{ URL_2_14 }}/$DOCKER_IP_2_14/g" scenarios.yml
sed -i "s/{{ URL_2_18 }}/$DOCKER_IP_2_18/g" scenarios.yml

# run graffiti
cd ~/graffiti
. venv/bin/activate
./graffiti.py --cfg ~/scenarios/scenarios.yml

# clear containers
cd ~/scenarios
docker-compose stop
docker-compose rm -f
