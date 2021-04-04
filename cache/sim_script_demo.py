from agents import *
from environment import *
import pickle

# Init variables
hv = 500         # n of HVs
av = 500         # n of AVs
N = 500          # n of Days
orig = '1'
dest = '9'
hv_err = 5        # error term on HV time perception ~N(0, hv_err)
hv_theta = .5     # rationality
hv_beta = .5      # prob of change route
hv_len = 3        # Memory lenth
hv_atis_bais = 0  # bias*prevTT + (1-bais)*memTT
av_err = 0
av_theta = 1
av_len = 1000     
av_atis_bias = 0

# Data save paths
route_dir = f"data/sim-ROUTES-N{N}-hv{hv}at{hv_err}_{hv_theta}_{hv_beta}_{hv_len}_{hv_atis_bais}-av{av}at{av_err}_{av_theta}_{av_len}_{av_atis_bias}.pickle"
roads_dir = f"data/sim-ROADS-N{N}-hv{hv}at{hv_err}_{hv_theta}_{hv_beta}_{hv_len}_{hv_atis_bais}-av{av}at{av_err}_{av_theta}_{av_len}_{av_atis_bias}.pickle"

# Square Network
roads = [Road('1', '2', 720, 20), Road('2', '3', 720, 12), Road('1', '4', 480, 15), Road('2', '5', 360, 12),
	Road('3', '6', 720, 12), Road('4', '5', 300, 10), Road('5', '6', 360, 12), Road('4', '7', 480, 15),
	Road('5', '8', 300, 10), Road('6', '9', 720, 30), Road('7', '8', 480, 15) ,Road('8', '9', 480, 15)]

# Make Network from roads
network = Network(roads)

# Make drivers
drivers = [HV(orig, dest, err = hv_err, theta = hv_theta, beta = hv_beta, L = hv_len) for i in range(0, hv)]
if av > 0:
    drivers = drivers + [AV(orig, dest, theta = av_theta, err = av_err, L = av_len, atis_bias = av_atis_bias) for i in range(0, av)]

# Day 1
for driver in drivers:
    driver.learn(network)
network.update(drivers)

# Make logs
count_log = pd.DataFrame(columns = [f'Road{i}' for i in range(len(network.roadlist))])
route_log = pd.DataFrame(columns = [f'Route{i}' for i in range(len(drivers[0].routes))])

# Save day 1 data
count_log.loc[0] = [road.count for road in network.roadlist]
route_count = [0 for route in range(len(drivers[0].routes))]
for driver in drivers:
    # Add one to route i, if driver took root i
    route_count[driver.i] = route_count[driver.i] + 1 
route_log.loc[0] = route_count

# Day > 1 Loop
for i in range(1,N):

    # Simulate
    for driver in drivers:
        driver.drive(network)
    network.update(drivers)
    
    # Save data
    count_log.loc[i] = [road.count for road in network.roadlist]
    route_count = [0 for route in route_log.keys()]
    for driver in drivers:
        route_count[driver.i] = route_count[driver.i] + 1
    route_log.loc[i] = route_count

# Export data to file for analysis
pickle.dump(route_log, open(route_dir, "wb" ))
pickle.dump(count_log, open(roads_dir, "wb" ))