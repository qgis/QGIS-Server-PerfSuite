#!/usr/bin/env python3
# coding: utf8

import os
import sys
import pandas
import argparse
import geopandas
from enum import Enum
from pgtoolkit import service
from sqlalchemy import create_engine
from distutils.dir_util import copy_tree
from shapely.geometry import Point, Polygon, LineString


class Datasource(Enum):
    GPKG = 1
    SHP = 2
    POSTGIS = 3


def generate(qgis2, outdir, datasource, perfsuite=False):
    n = 0

    outfile = None
    datadir = None
    if datasource == Datasource.GPKG:
        outfile = os.path.join(outdir, "geopackage.qgs")
    elif datasource == Datasource.SHP:
        outfile = os.path.join(outdir, "shapefile.qgs")
        datadir = os.path.join(outdir, "data")
        if not os.path.isdir(datadir):
            os.mkdir(datadir)
    else:
        if perfsuite:
            url = "postgresql://root:@/data?host=/var/run/postgresql"
            service_name = "data_perf"
        else:
            service_name = "data_perf"
            path = service.find()
            with open(path) as f:
                data = service.parse(f)
                s = data[service_name]
                url = "postgresql://{}:{}@{}:{}/{}".format(
                    s.user, s.password, s.host, s.port, s.dbname
                )
        outfile = os.path.join(outdir, "postgis.qgs")

    p0 = Point(0, 0)
    p1 = Point(1, 0)
    p2 = Point(1, 1)

    geom = None
    layers = False

    # copy svgs
    cwd = os.path.dirname(os.path.abspath(__file__))
    svgs = os.path.join(cwd, "symbols")
    copy_tree(svgs, os.path.join(outdir, "symbols"))

    template = "template.qgs"
    if qgis2:
        template = "template_218.qgs"

    with open(os.path.join(os.path.dirname(__file__), template), "r") as inp:
        with open(outfile, "w") as out:
            for line in inp:
                if "<projectlayers" in line:
                    layers = True

                if "</projectlayers" in line:
                    layers = False

                if not layers:
                    out.write(line)
                    continue

                if "<maplayer" in line:
                    for field in line.split(" "):
                        if "geometry" in field:
                            geom = field.split("=")[1].replace('"', "").lower()

                if "</maplayer" in line:
                    geom = None

                if "<provider" in line and "</provider" in line:
                    if datasource == Datasource.SHP or datasource == Datasource.GPKG:
                        line = "      <provider>ogr</provider>\n"
                    if datasource == Datasource.POSTGIS:
                        line = "      <provider>postgres</provider>\n"

                if not geom:
                    out.write(line)
                    continue

                if "<datasource" in line:
                    if geom == "polygon":
                        poly = Polygon([[p.x, p.y] for p in [p0, p1, p2]])
                        d = {"geometry": [poly]}
                    elif geom == "point":
                        d = {"geometry": [p0]}
                    elif geom == "line":
                        line = LineString([p0, p1])
                        d = {"geometry": [line]}

                    pdf = geopandas.GeoDataFrame(d)

                    if datasource == Datasource.SHP:
                        shp = os.path.join(datadir, "shapefile_{}.shp".format(n))
                        if os.path.isfile(shp):
                            os.remove(shp)
                        pdf.to_file(shp)

                        shp = os.path.join("data", "shapefile_{}.shp".format(n))
                        line = "      <datasource>./{}</datasource>\n".format(shp)
                    elif datasource == Datasource.GPKG:
                        layername = "layer_{}".format(n)
                        gpkg = os.path.join(outdir, "database.gpkg")
                        pdf.to_file(gpkg, layer=layername, driver="GPKG")

                        line = "      <datasource>./database.gpkg|layername={}</datasource>\n".format(
                            layername
                        )
                    elif datasource == Datasource.POSTGIS:
                        engine = create_engine(url)
                        layername = "layer_{}".format(n)
                        try:
                            pdf.to_postgis(name=layername, con=engine)
                        except ValueError:
                            pass

                        line = "      <datasource>service='{}' srid=0 type={} table=\"{}\" (geometry)</datasource>\n".format(
                            service_name, geom, layername
                        )

                    n += 1
                    geom = None

                out.write(line)


if __name__ == "__main__":

    # Command line parser
    parser = argparse.ArgumentParser(description="")
    parser.add_argument(
        "--shp", help="Output directory with a project based on shapefiles", type=str
    )
    parser.add_argument(
        "--gpkg", help="Output directory with a project based on geopackage", type=str
    )
    parser.add_argument(
        "--postgis", help="Output directory with a project based on postgis", type=str
    )
    parser.add_argument(
        "--pf",
        help="Store the PostGIS data in the perfsuite database.",
        action="store_true",
    )
    parser.add_argument(
        "--qgis2",
        help="Use the QGIS 2 template.",
        action="store_true",
    )
    args = parser.parse_args()

    if args.shp:
        if not os.path.isdir(args.shp):
            print("Invalid input directory")
            sys.exit(1)
        generate(args.qgis2, args.shp, Datasource.SHP)

    if args.gpkg:
        generate(args.qgis2, args.gpkg, Datasource.GPKG)

    if args.postgis:
        generate(args.qgis2, args.postgis, Datasource.POSTGIS, args.pf)
