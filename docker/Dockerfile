# Docker container that builds QGIS Server 3.x
# for performance test builds in release mode
# ARGUMENTS:
# - VERSION: the 3.x QGIS git tag/release to build (ex: "release-3_16" or "master")

ARG VERSION=latest
FROM qgis/qgis3-build-deps:${VERSION}

MAINTAINER Alessandro Pasotti <elpaso@itopen.it>
LABEL Description="Docker container with QGIS Server for performance test builds" Vendor="ItOpen" Version="1.0"

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive

ARG VERSION
ENV VERSION=$VERSION

COPY assets/*.sh /
COPY assets/pg_service.conf /root/.pg_service.conf

RUN apt install bc

RUN /clone.sh $VERSION && /build.sh
