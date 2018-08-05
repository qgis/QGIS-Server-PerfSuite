FROM debian:stretch
MAINTAINER Paul Blottiere <blottiere.paul@gmail.com>
RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
  bison \
  build-essential \
  ca-certificates \
  ccache \
  cmake \
  dh-python \
  expect \
  flex \
  gdal-bin \
  git \
  libexpat1-dev \
  libfcgi-dev \
  libgdal-dev \
  libgeos-dev \
  libgsl-dev \
  libosgearth-dev \
  libpq-dev \
  libproj-dev \
  libqca-qt5-2-dev \
  libqca-qt5-2-plugins \
  libqt5opengl5-dev \
  libqt5scintilla2-dev \
  libqt5sql5-sqlite \
  libqt5svg5-dev \
  libqt5webkit5-dev \
  libqt5xmlpatterns5-dev \
  libqt5serialport5-dev \
  libqwt-qt5-dev \
  libspatialindex-dev \
  libspatialite-dev \
  libsqlite3-dev \
  libsqlite3-mod-spatialite \
  libzip-dev \
  lighttpd \
  locales \
  pkg-config \
  poppler-utils \
  pyqt5-dev \
  pyqt5-dev-tools \
  pyqt5.qsci-dev \
  python3-all-dev \
  python3-dateutil \
  python3-dev \
  python3-future \
  python3-gdal \
  python3-httplib2 \
  python3-jinja2 \
  python3-markupsafe \
  python3-mock \
  python3-nose2 \
  python3-owslib \
  python3-plotly \
  python3-psycopg2 \
  python3-pygments \
  python3-pyproj \
  python3-pyqt5 \
  python3-pyqt5.qsci \
  python3-pyqt5.qtsql \
  python3-pyqt5.qtsvg \
  python3-requests \
  python3-sip \
  python3-sip-dev \
  python3-six \
  python3-termcolor \
  python3-tz \
  python3-yaml \
  qt5-default \
  qt5keychain-dev \
  qtbase5-dev \
  qtpositioning5-dev \
  qttools5-dev \
  qttools5-dev-tools \
  spawn-fcgi \
  postgresql-client

WORKDIR /root

RUN git clone https://github.com/qgis/QGIS
RUN cd QGIS && mkdir build
RUN cd QGIS/build && cmake -DWITH_SERVER=ON .. && make -j4 && make install && ldconfig
RUN rm -rf /root/QGIS

ADD cmd.sh /root/cmd.sh

COPY pg_service.conf /root/.pg_service.conf

WORKDIR /
CMD ["sh", "/root/cmd.sh"]
