#! /bin/bash

cd /root/QGIS/build
make -j4
make install
ldconfig
rm -rf /root/QGIS
