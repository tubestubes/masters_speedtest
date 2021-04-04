include("./env.jl")
using env

module agn
using Random, Distributions
export Driver, learn!, drive! 

function problist(plist::Array{Float64}, beta::Float64, theta::Float64)
    top = [ exp(-(theta)*p) for p in plist]
    sums = sum(top)
    if sums == 0
        throw("Div by 0")
    end
    qlist = [ beta * top[i]/sums for i in 1:length(top)]
    return qlist
end

mutable struct Driver
    origin::Char
    destination::Char
    beta::Float64
    theta::Float64
    l::Int
    err::Int
    bias::Float64
    memory::Array{Any}
    routes::Array{Any}
    route::Array{Any}
    i::Int
end

function learn!(driver::Driver, network::Network)
    # Init driver knowlage
    driver.memory = Dict( road => [road.freeflow + rand(Normal(0, driver.err*10))] for road in network.roadlist )
    driver.routes = network.routes

    # Choose route
    ett = []
    for route in routes
        tt = 0
        for road in route
            tt = tt + (1 - driver.bias)*driver.memory[road] + driver.bias * road.tt
        end
        append!(ett, tt)
    end
    probs = problist(ett, 1, driver.theta)
    rando = rand(Uniform(0, 1))
    i = 1
    while rand > sum( [probs[j] for j in 1:i] )
        i += 1
    end
    
    # Record Decision
    driver.route = driver.routes[i]
    driver.i = i
end

function drive!(driver::Driver, network::Network)

    # Update memory
    for road in driver.route
        append!(driver.memory[road], road.tt + rand(Normal(0, driver.err)))
        if lenth(driver.memory[road]) == driver.l + 1
            driver.memory[road] = driver.memory[road][2:end]
        end 
    end

    # Choose route
    ett = []
    for route in routes
        tt = 0
        for road in route
            tt = tt + (1 - driver.bias)*driver.memory[road] + driver.bias * road.tt
        end
        append!(ett, tt)
    end
    deleteat!(ett,i)
    probs = problist(ett, driver.beta, driver.theta)
    p_same = 1 - driver.beta
    insert!(probs, i, p_same)
    rando = rand(Uniform(0, 1))
    i = 1
    while rand > sum( [probs[j] for j in 1:i] )
        i += 1
    end

    # Record Decision
    driver.route = driver.routes[i]
    driver.i = i

end


# Test Code
println(problist([0.25, 0.25, 0.5], .5, 1.0)) # [.1799, .1799, .1401]

# Module
end