# Agent Definitions
# Generic driver class, then HV and AV classes

import pandas as pd
from random import uniform, gauss
from math import exp


# Probablity of route from perceived travel time list
def problist(plist, beta, theta):
    plist = [p for p in plist]
    top = [exp(-(theta) * p) for p in plist]
    sums = sum(top)
    if sums == 0:
        raise Exception("Probablites came out as 0 as e^-theta*p is too small. The Roads are probably over capacity.")
    qlist = [beta * top[i] / sums for i in range(0, len(top))]
    return qlist


# Generic Vehicle Class
class Driver:
    type = "GV"

    def __init__(self, origin, destination, beta = .5, theta = .5, L = 3, err = .1, atis_bias = 0.5):
        self.origin = origin
        self.destination = destination
        self.beta = beta
        self.theta = theta
        self.L = L
        self. err = err
        self.bias = atis_bias

    def __str__(self):
        return f"{self.type}:{(self.origin, self.destination)}"

    # Driver learns network
    def learn(self, network):
        # init ett = freeflow tt + error
        self.memory = {road:[float(road.freeflow) + gauss(0, self.err*10)] for road in network.roadlist}

        # Get routes and ETTs
        self.routes = network.routes(self.origin, self.destination)
        ett = []
        for route in self.routes:
            tt = 0
            for road in route:
                tt = tt  +  (1-self.bias) * self.memory[road][0]  +  self.bias * road.tt(network)
            ett.append(tt)

        # Init route choose
        probs = problist(ett, 1, self.theta)  # beta = 1 as must pick new route
        rand = uniform(0, 1)
        i = 0
        while rand > sum([probs[j] for j in range(i + 1)]):
            i += 1
        self.route = self.routes[i]
        self.i = i

    def drive(self, network):
        # Update ETTs in roads
        for road in self.route:
            self.memory[road].append(road.tt(network) + gauss(0, self.err))
            if len(self.memory[road]) == self.L + 1:
                self.memory[road].pop(0)  # Only up to L days memory

        # Update ETTs in routes
        ett = []
        for route in self.routes:
            tt = 0
            for road in route:
                tt = tt + (1-self.bias)*(sum(self.memory[road]) / len(self.memory[road])) + self.bias*road.tt(network)
            ett.append(tt)

        # Choose next route
        ett.pop(self.i)
        probs = problist(ett, self.beta, self.theta)  # p of routes iff change
        p_same = 1 - self.beta  # p no change
        probs.insert(self.i, p_same)
        rand = uniform(0, 1)
        i = 0
        while rand > sum([probs[j] for j in range(i + 1)]):
            i += 1
        self.route = self.routes[i]
        self.i = i

    def display(self):
        df = pd.DataFrame(self.memory.keys(), columns=["Road"])
        df['Memory'] = list(self.memory.values())
        etts = []
        for road in self.memory.keys():
            ett = sum(self.memory[road]) / len(self.memory[road])
            etts.append(ett)
        df['ETT'] = etts
        print(f"Last route: route {self.i}:{self.route}")
        return df


# Autonomous class
class AV(Driver):
    type = 'AV'

    def __init__(self, origin, destination, theta = 1, L = 1000, err = 0, atis_bias = .5):
        super().__init__(origin, destination, theta = theta , L = L, err = err, atis_bias = atis_bias)


    # Edited to update ALL roads
    def drive(self, network):

        for road in network.roadlist:
            self.memory[road].append(road.tt(network))
            if len(self.memory[road]) == self.L + 1:
                self.memory[road].pop(0)

        ett = []
        for route in self.routes:
            tt = 0
            for road in route:
                tt = tt + (1-self.bias)*(sum(self.memory[road]) / len(self.memory[road])) + self.bias*road.tt(network)
            ett.append(tt)

        # Choose next route from ALL roads
        probs = problist(ett, 1, self.theta)
        rand = uniform(0, 1)
        i = 0
        while rand > sum([probs[j] for j in range(i + 1)]):
            i += 1
        self.route = self.routes[i]
        self.i = i


class HV(Driver):
    type = 'HV'
