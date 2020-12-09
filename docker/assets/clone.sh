#!/bin/bash
# Script that can be run inside the docker to build QGIS Server
# Checkout QGIS sources in "/qgis_sources" folder
# Arguments: VERSION branch to checkout

if [ "$VERSION" = "" ]; then
    VERSION=$1
fi

if [ "$VERSION" = "latest" ]; then
    VERSION="master"
fi

echo "Cloning QGIS sources branch: ${VERSION}"
git clone --single-branch --depth 1 --branch ${VERSION} https://github.com/qgis/QGIS.git /qgis_sources
