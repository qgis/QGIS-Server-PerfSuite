#! /usr/bin/env bash

BASEDIR=$(dirname $(realpath -s $0))

cd ${BASEDIR}/2.14 && sh build.sh
cd ${BASEDIR}/2.18 && sh build.sh
cd ${BASEDIR}/3.2 && sh build.sh
cd ${BASEDIR}/3.4 && sh build.sh
cd ${BASEDIR}/3.6 && sh build.sh
cd ${BASEDIR}/master && sh build.sh
cd ${BASEDIR}/data && sh build.sh
