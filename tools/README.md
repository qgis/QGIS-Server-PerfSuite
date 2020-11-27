# Tools

Add tools to create qgs projects from a template and for various data sources.

```` bash
$ cd tools
$ virtualenv venv
$ source venv/bin/activate
(venv)$ pip install -r requirements.txt
````

#### Shapefile

Run the `template.py` script to create a shapefile based qgs project and create
the corresponding shapefiles in the `data` subdirectory:

```` bash
(venv)$ rm -rf shp/
(venv)$ mkdir shp
(venv)$ ./template.py --shp ./shp
(venv)$ ls shp/
data  shapefile.qgs
````

The `shapefile.qgs` project may be opened with QGIS Desktop but the maximum
number of open file descriptors needs to be increased:

```` bash
$ ulimit -n 4096
````

#### Geopackage

Run the `template.py` script to create a gopackage based qgs project and create
the database:

```` bash
(venv)$ rm -rf gpkg/
(venv)$ mkdir gpkg
(venv)$ ./template.py --gpkg ./gpkg
(venv)$ ls gpkg/
database.gpkg  geopackage.qgs
````

The `geopackage.qgs` project may be opened with QGIS Desktop.

#### PostGIS

Create database and PostGIS extension:

```` bash
$ dropdb --if-exists perfsuite
$ createdb perfsuite
$ psql perfsuite -c "CREATE EXTENSION postgis;"
````

Add an entry in the `pg_service.conf` file:

```` bash
[perfsuite]
host=localhost
dbname=perfsuite
port=5432
user=username
password=pwd
````

Run the `template.py` script to create a postgis based qgs project and fill the
database:

```` bash
(venv)$ rm -rf postgis/
(venv)$ mkdir postgis
(venv)$ ./template.py --postgis ./postgis
(venv)$ ls postgis/
postgis.qgs
(venv)$ psql perfsuite -c "\dt"
               List of relations
 Schema |      Name       | Type  |   Owner
--------+-----------------+-------+------------
 public | layer_0         | table | pblottiere
 public | layer_1         | table | pblottiere
 public | layer_10        | table | pblottiere
 public | layer_100       | table | pblottiere
 public | layer_101       | table | pblottiere
 public | layer_102       | table | pblottiere
 public | layer_103       | table | pblottiere
 public | layer_104       | table | pblottiere
...
...
...
````

The `postgis.qgs` project may be opened with QGIS Desktop.
