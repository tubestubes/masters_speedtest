#include("./env.jl")
include("./agn.jl")
#using .env, .agn

# Global Parameters
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

# Define Roads
roads = [Road('1', '2', 720, 20,0,0,0), Road('2', '3', 720, 120, 0, 0, 0), Road('1', '4', 480, 15, 0, 0, 0), Road('2', '5', 360, 12, 0, 0, 0),
	Road('3', '6', 720, 12, 0, 0, 0), Road('4', '5', 300, 10, 0, 0, 0), Road('5', '6', 360, 12, 0, 0, 0), Road('4', '7', 480, 15, 0, 0, 0),
	Road('5', '8', 300, 10, 0, 0, 0), Road('6', '9', 720, 30, 0, 0, 0), Road('7', '8', 480, 15, 0, 0, 0) ,Road('8', '9', 480, 15, 0, 0, 0)]

# Prepare network
netparams = Net_Params(length(roads), 0.9,1.2,0.75,5)

# Init tt's
for road in roads
	update_tt!(road, netparams)
end

# Make network
network = make_network(roads, '1', '9')

# Make drivers
drivers = [Driver(orig, dest, hv_beta, hv_theta, hv_len, hv_err, hv_atis_bais, 0, [], [], 0) for _ in 1:hv]


# Learn + drive day 1
for driver in drivers
	learn!(driver, network)
end

# Update network
update!(network, drivers)

# TODO
# - Store data
# cont'n sim loop
# - Plot

