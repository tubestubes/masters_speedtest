#module env
#export Net_Params, Road, update_tt!, make_network, update!, Network

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

function make_network(roads::Array{Road}, origin::Char, destination::Char)

    # Pathfinder
    routes = []
    # Starting roads
    explore = [road for road in roads if road.start == origin]

    # check if start roads reach destination
    closed = [[road] for road in explore if road.endd == destination]
    append!(routes ,closed)
    # Open for exploration, looped until done
    opn = [road for road in explore if road ∉ closed]
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
    for road in net.roadlist
        count = 0
        av_count = 0
        for driver in drivers
            if road in driver.route
                count += 1
                #if driver.type == "AV"
                #    av_count += 1
                # end
             end
        end
        road.count = count
        road.av_count = av_count
    end
end

# Test Code
function test()
    println(traveltime(100,10,100))
    println(avgain(1,1,1,1,1))

    roads = [Road('1', '2', 720, 20,0,0,0), Road('2', '3', 720, 120, 0, 0, 0), Road('1', '4', 480, 15, 0, 0, 0), Road('2', '5', 360, 12, 0, 0, 0),
	Road('3', '6', 720, 12, 0, 0, 0), Road('4', '5', 300, 10, 0, 0, 0), Road('5', '6', 360, 12, 0, 0, 0), Road('4', '7', 480, 15, 0, 0, 0),
	Road('5', '8', 300, 10, 0, 0, 0), Road('6', '9', 720, 30, 0, 0, 0), Road('7', '8', 480, 15, 0, 0, 0) ,Road('8', '9', 480, 15, 0, 0, 0)]

    network = make_network(roads, '1', '9')
    println(network.routes)
end

if abspath(PROGRAM_FILE) == @__FILE__
    test()
end

#Module
#end

