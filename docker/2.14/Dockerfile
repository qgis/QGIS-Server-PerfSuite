FROM debian:stretch
MAINTAINER Paul Blottiere <blottiere.paul@gmail.com>
RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
  git \
  cmake \
  g++ \
  bison \
  flex \
  libgdal-dev \
  libqt4-dev \
  libqtwebkit-dev \
  libqt4-sql-sqlite \
  libqwt-dev \
  libqca2-dev \
  libspatialindex-dev \
  libspatialite-dev \
  python-all-dev \
  python-sip-dev \
  python-qt4-dev \
  pyqt4-dev-tools \
  libgsl-dev \
  libqscintilla2-dev \
  libfcgi-dev \
  spawn-fcgi \
  postgresql-client

WORKDIR /root

RUN git clone https://github.com/qgis/QGIS
RUN cd QGIS && git checkout release-2_14 && mkdir build
RUN cd QGIS/build && cmake -DCMAKE_BUILD_TYPE=Release -DWITH_SERVER=ON .. && make -j4 && make install && ldconfig
RUN rm -rf /root/QGIS

ADD cmd.sh /root/cmd.sh

COPY pg_service.conf /root/.pg_service.conf

WORKDIR /
CMD ["sh", "/root/cmd.sh"]
