FROM debian:stretch
MAINTAINER Paul Blottiere <blottiere.paul@gmail.com>
RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
  git \
  cmake \
  g++ \
  xvfb \
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
  nginx \
  spawn-fcgi

WORKDIR /root

RUN git clone https://github.com/qgis/QGIS
RUN cd QGIS && git checkout release-2_14 && mkdir build
RUN cd QGIS/build && cmake -DWITH_SERVER=ON .. && make -j4 && make install && ldconfig
RUN rm -rf /root/QGIS

ADD cmd.sh /root/cmd.sh

EXPOSE 80
ADD nginx.conf /etc/nginx/sites-available/default

WORKDIR /
CMD ["sh", "/root/cmd.sh"]
