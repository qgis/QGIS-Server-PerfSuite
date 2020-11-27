#!/usr/bin/env python
# coding: utf8

import os
import sys
import pandas
import argparse
import geopandas
from enum import Enum
from shapely.geometry import Point, Polygon


class Datasource(Enum):
    GPKG = 1
    SHP = 2
    BLUE = 3


def generate(outdir, datasource):
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
        return

    p0 = Point(0, 0)
    p1 = Point(1, 0)
    p2 = Point(1, 1)

    geom = None
    layers = False

    with open("template.qgs", "r") as inp:
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

                if not geom:
                    out.write(line)
                    continue

                if "<datasource" in line:
                    if geom == "polygon":
                        poly = Polygon([[p.x, p.y] for p in [p0, p1, p2]])
                        d = {"geometry": [poly]}

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
    args = parser.parse_args()

    if args.shp:
        if not os.path.isdir(args.shp):
            print("Invalid input directory")
            sys.exit(1)
        generate(args.shp, Datasource.SHP)

    if args.gpkg:
        generate(args.gpkg, Datasource.GPKG)
