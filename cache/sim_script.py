from agents import *
from environment import *
import pickle


route_dir = f"data/sim-ROUTES-N{N}-hv{hv}at{hv_err}_{hv_theta}_{hv_beta}_{hv_len}_{hv_atis_bais}-av{av}at{av_err}_{av_theta}_{av_len}_{av_atis_bias}.pickle"
roads_dir = f"data/sim-ROADS-N{N}-hv{hv}at{hv_err}_{hv_theta}_{hv_beta}_{hv_len}_{hv_atis_bais}-av{av}at{av_err}_{av_theta}_{av_len}_{av_atis_bias}.pickle"

network = Network(roads)

drivers = [HV(orig, dest, err = hv_err, theta = hv_theta, beta = hv_beta, L = hv_len) for i in range(0, hv)]
if av > 0:
    drivers = drivers + [AV(orig, dest, theta = av_theta, err = av_err, L = av_len, atis_bias = av_atis_bias) for i in range(0, av)]

for driver in drivers:
    driver.learn(network)
network.update(drivers)

count_log = pd.DataFrame(columns = [f'Road{i}' for i in range(len(network.roadlist))])
count_log.loc[0] = [road.count for road in network.roadlist]
route_log = pd.DataFrame(columns = [f'Route{i}' for i in range(len(drivers[0].routes))])
route_count = [0 for route in range(len(drivers[0].routes))]
for driver in drivers:
    route_count[driver.i] = route_count[driver.i] + 1
route_log.loc[0] = route_count

for i in range(1,N):

    for driver in drivers:
        driver.drive(network)
    network.update(drivers)
    
    count_log.loc[i] = [road.count for road in network.roadlist]
    route_count = [0 for route in route_log.keys()]
    for driver in drivers:
        route_count[driver.i] = route_count[driver.i] + 1
    route_log.loc[i] = route_count

pickle.dump(route_log, open(route_dir, "wb" ))
pickle.dump(count_log, open(roads_dir, "wb" ))