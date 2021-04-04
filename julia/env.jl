#Envrionment Module
module env


function traveltime(count, freeflow, capacity)
    tt = freeflow * (1 + 1.15 * ((count / capacity) ^ 4))
    return tt
end


function avgain(g, ba, br, n, a)
    if a == 0
        e = 1 - g - (ba - g) / n
    else
        e = 1 - g - ((ba - g) / n + (br - 1) / n)
    end
    return e
end


struct Net_Params
    nroads::Int
    ba::Float64
    br::Float64
    g::Float64
    n::Int
 end


mutable struct Road
    start::Char
    endd::Char
    capacity::Int
    freeflow::Float64
    count::Int
    av_count::Int
    tt::Float64
end

function update_tt!(road::Road, net::Net_Params)
    if road.count != 0
        a = road.av_count / road.count
    else 
        a = 0
    end

    e = avgain(net.g, net.br, net.ba, net.n, a)
    capacity = road.capacity / (1 - a * e)
    tt = traveltime(road.count, road.freeflow, capacity)
    
    # Return: Mutate road
    road.tt = tt
end

struct Network
    roadlist
    routes
end

function make_network(roads::Array{Road,1}, origin::Char, destination::Char)

    # Pathfinder
    routes = []
    # Starting roads
    explore = [road for road in roads if road.start == origin]
    # check if start roads reach destination
    closed = [[road] for road in explore if road.endd == destination]
    append!(routes ,closed)
    # Open for exploration, looped until done
    opn = [road for road in explore if road !== closed]
    explore = []

    for entry in opn
        next = [[entry, road] for road in roads if road.start == entry.endd]
        append!(explore,next)
    end

    while length(explore) > 0
        for path in explore
            #pop!(explore, path)
            explore = [entry for entry in explore if entry !== path]
            end_road = path[end]
            if end_road.endd == destination 
                append!(routes, [path])
            end
            end_explore = [road for road in roads if road.start == end_road.endd]
            closed = [vcat(path,[road]) for road in end_explore if road.endd == destination]
            append!(routes, closed)
            opn = [vcat(path,[road]) for road in end_explore if road.endd !== destination]
            append!(explore, opn)
        end
    end   
    
    return Network(roads, routes)
end

#TODO
function update!(net::Network, drivers)
for road in net.roadlist:
    count = 0
    av_count = 0
    for driver in drivers:
        if road in driver.route:
            count += 1
            if driver.type == 'AV':
                av_count += 1
    road.count = count
    road.av_count = av_count

# Test Code
println(traveltime(100,10,100))
println(avgain(1,1,1,1,1))

roads = [Road('0', '1', 100, 20, 0, 0, 20), Road('0', '2', 200, 20, 0, 0, 20), Road('2', '3', 100, 20, 0, 0, 20), 
Road('1', '3', 200, 20, 0, 0, 20), Road('2', '1', 100, 20, 0, 0, 20)]

network = make_network(roads, '0', '3')

println(network.routes)
  

end

