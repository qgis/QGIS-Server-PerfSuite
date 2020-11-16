import sys

from graffiti.graffiti.request import Request
from graffiti.graffiti.config import Config
from graffiti.graffiti.database import Database

TOLERANCE = 5  # percentage

cfg = Config('scenarios.yml', 'style.yml')
database = Database(cfg.database)

regressions = 0

for r in cfg.requests:
    r.provider = None
    req = Request.build(r)
    means = database.means(req, limit=30, min=0.05)

    if not means:
        continue

    for host in req.hosts:
        # check regressions for Master branch only
        if "Master" not in host.name:
            continue

        mean = means[host.name]
        if not mean:
            continue

        last = mean[0][1]
        last_mean = mean[1][1]
        for m in mean[2:-1]:
            least_mean = (last_mean+m[1])/2

        if last > (last_mean + TOLERANCE*last_mean/100):
            regressions = 1
            msg = "[{}.{}] Last result '{}' is above the '{}%' tolerance compared to the monthly mean '{}'".format(req.name, host.name, last, TOLERANCE, last_mean)
            print(msg)

sys.exit(regressions)
