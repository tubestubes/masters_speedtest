@time begin
include("./agn.jl")
using DataFrames, StatsPlots

# Global Parameters
hv = 1000         # n of HVs
av = 0         # n of AVs
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

# Init logs
route_log = DataFrame(Route1 = Int[], Route2 = Int[] ,Route3 = Int[] ,Route4 = Int[] ,Route5 = Int[] ,Route6 = Int[])
road_log = DataFrame(Road1 = Int[], Road2 = Int[], Road3 = Int[], Road4 = Int[], Road5 = Int[], Road6 = Int[], Road7 = Int[], Road8 = Int[], Road9 = Int[],Road10 = Int[], Road11 = Int[], Road12 = Int[])

# Learn + drive day 1
for driver in drivers
	learn!(driver, network)
end
update!(network, drivers)
push!(road_log, [road.count for road in network.roadlist])
route_count = [0 for road in 1:length(network.routes)]
for driver in drivers
	route_count[driver.i] += 1
end
push!(route_log, route_count)

# Day 2..N
for i in 2:N
	for driver in drivers
		learn!(driver, network)
	end
	update!(network, drivers)
	push!(road_log, [road.count for road in network.roadlist])
	route_count = [0 for road in 1:length(network.routes)]
	for driver in drivers
		route_count[driver.i] += 1
	end
	push!(route_log, route_count)
end

end

# Test Code
#route_log[!, :day] = 1:length(route_log.Route1)
#print(first(route_log, 10))
#@df route_log plot(:day, [:Route1 :Route2 :Route3 :Route4 :Route5 :Route6])



