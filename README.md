# QGIS Server PerfSuite

The goal of this project is to provide a simple and convenient way to deploy an infrastructure for
assessing the performance of [QGIS Server](https://github.com/qgis/QGIS).

The repo includes:

- Dockerfiles for building and executing QGIS Server 2.14, 2.18, 3.0 and Master
- A Dockerfile for PostGIS and test data
- Ansible scripts for remote deployment
- some tests to generate a HTML report with [Graffiti](https://github.com/pblottiere/graffiti)
- everything needed for running your own test scenarios with you own QGIS Server version!

<p align="center">
  <img src="https://github.com/Oslandia/QGIS-Server-PerfSuite/blob/master/docs/arch.png" width="550" title="Arch image">
</p>

Moreover, considering that `docker-compose` is used to run the tests, QGIS
Server may be configured through environment variables (to activate the
parallel rendering for example).

Note that if you just want to measure the performance of an already-running QGIS Server you
just need to use [Graffiti](https://github.com/pblottiere/graffiti) without
the whole infrastructure.

<p align="center">
  <img src="https://github.com/Oslandia/QGIS-Server-PerfSuite/blob/master/docs/report.png" width="550" title="Report">
</p>

## Clone

To clone the project:

```
$ git clone https://Oslandia/QGIS-Server-Perfsuite
$ cd QGIS-Server-Perfsuite
$ ls
ansible  docker  docs  README.md  scenarios
```

Description of the content:
- ansible: directory with Ansible scripts for a remote deployment
- docker: directory with Dockerfiles for QGIS Server and PostGIS (with data)
- README.md: the current file
- scenarios: `docker-compose.yml` and configuration files for Graffiti

## Deployment

#### Local deployment with Dockerfiles only

If you just want to execute Graffiti and its tests on your machine, you just
need to build Docker images first (for QGIS Server and PostGIS + data):

**Warning** this will clone QGIS repository and compile QGIS, which takes a lot of disk space and compile time. 

```
$ cd docker
$ sh build.sh
```

#### Remote deployment with Ansible

To deploy this project on a remote server, you have to:
- configure your SSH to have a root connection without password (ssh key)
- create an alias in your `~/.ssh/config` for the host `qgis-perfsuite` (for
  the `root` user)
- execute the Ansible playbook for the virtualenv (see below)

```
$ cd ansible
$ virtualenv -p /usr/bin/python2 venv
$ source venv/bin/activate
(venv)$ pip install -r requirements.txt
(venv)$ ansible-playbook -i hosts playbook.yml
```

#### Local deployment on a Vagrant machine with Ansible

It's not necessarily a good idea to use a Vagrant machine to run the underlying
tests, but it may be convenient for testing:

```
$ cd ansible
$ virtualenv -p /usr/bin/python2 venv
$ source venv/bin/activate
(venv)$ cd vagrant
(venv)$ vagrant plugin install vagrant-disksize
(venv)$ sh vagrant.sh up
```

## Running tests

Once deployed (locally or remotely), you just have to execute the next script
to run Graffiti:

```
$ cd scenarios
$ sh run.sh
```

Then the generated HTML report should be `/tmp/graffiti/report.html`.

Note that the data used for testing is in the `scenarios/data` subdirectory.

## Write your own tests

The tool used to run and generate the report is [Graffiti](https://github.com/pblottiere/graffiti),
so you should take a look at its documentation first.

#### Modify the current scenario

If you just want to modify or add some tests in the current infrastructure
without adding/updating a QGIS Server instance, you may:
- update the `scenarios.sample.yml` file
- update `*.html` description files

#### Configure a QGIS Server instance

If you just want to add a QGIS Server instance with some specific configuration
based on environment variables, you can take a look at the `docker-compose.yml`
file. For example, if you want to add a QGIS Server 3.0 instance with 8 cores
to test the parallel rendering:

```
  qgis-3.0-parallel-rendering-8-cores:
    container_name: qgisserver-perfsuite-3.0-parallel-rendering-8-cores
    image: qgisserver-perfsuite/3.0
    volumes:
      - ./data:/data
    links:
      - data
    environment:
      - QGIS_SERVER_PARALLEL_RENDERING=1
      - QGIS_SERVER_MAX_THREADS=8
```

#### Add a test with a custom project and custom data

If you want to run some tests with a custom `.qgs` project, you need to
add your project to the `scenarios/data` subdirectory. Moreover, if your
data is based on GeoTIIF, Shapefile, ... files, you also need to copy the
date files to `scenarios/data`. In this way the Docker containers will
be able to use them!
