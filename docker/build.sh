#! /usr/bin/env bash

BASEDIR=$(dirname "$0")

cd ${BASEDIR}/2.14 && sh build.sh
cd ${BASEDIR}/2.18 && sh build.sh
cd ${BASEDIR}/3.0 && sh build.sh
cd ${BASEDIR}/master && sh build.sh
cd ${BASEDIR}/data && sh build.sh
