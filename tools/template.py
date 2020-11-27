#!/usr/bin/env python
# coding: utf8

import os
import sys
import pandas
import argparse
import geopandas
from shapely.geometry import Point, Polygon


def shapefile(outdir):
    n = 0
    outfile = os.path.join(outdir, "shapefile.qgs")

    datadir = os.path.join(outdir, "data")
    if not os.path.isdir(datadir):
        os.mkdir(datadir)

    p0 = Point(0,0)
    p1 = Point(1,0)
    p2 = Point(1,1)

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
                            geom = field.split("=")[1].replace("\"", "").lower()

                if "</maplayer" in line:
                    geom = None

                if "<provider" in line and "</provider" in line:
                    line = "      <provider>ogr</provider>\n"

                if not geom:
                    out.write(line)
                    continue

                if "<datasource" in line:
                    if geom == "polygon":
                        poly = Polygon([[p.x, p.y] for p in [p0, p1, p2]])
                        d = {'geometry': [poly]}

                    pdf = geopandas.GeoDataFrame(d)

                    shp = os.path.join(datadir, "shapefile_{}.shp".format(n))
                    if os.path.isfile(shp):
                        os.remove(shp)
                    pdf.to_file(shp)

                    shp = os.path.join("data", "shapefile_{}.shp".format(n))
                    line = "      <datasource>./{}</datasource>\n".format(shp)

                    n += 1
                    geom = None

                out.write(line)


if __name__ == "__main__":

    # Command line parser
    parser = argparse.ArgumentParser(description="")
    parser.add_argument("--shp", help="Output directory with a project based on empty shapefiles", type=str)
    args = parser.parse_args()

    if args.shp:
        if not os.path.isdir(args.shp):
            print("Invalid input directory")
            sys.exit(1)
        shapefile(args.shp)
