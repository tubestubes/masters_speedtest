# Envronment Definitions
# From roads to Networks, plus some functions
# Function to calc tt from count, ff, capacity
# Function to calc av gain from params

import pandas as pd

# Travel time fn
def traveltime(count, freeflow, capacity):
    tt = freeflow * (1 + 1.15 * ((count / capacity) ** 4))
    return tt


# AV gain fn
def avgain(g, ba, br, n, a):
    """ g: av spacing
        ba: av spacing bebind hv
        br: hv spacing behind av
        n: platoon lenth
        all as propotions of hv-hv spacing
    """
    if a == 0:
        e = 1 - g - (ba - g) / n
    else:
        e = 1 - g - ((ba - g) / n + (br - 1) / n)
    return e


# Road: From a to b with capacity c, free flow f, and count, av count, and traveltime()
class Road:
    def __init__(self, a, b, c, f):
        self.start = a
        self.end = b
        self.capacity = c
        self.freeflow = f
        self.count = 0
        self.av_count = 0

    def tt(self, network):
        # Adjust capacity for AVs, based on network's AV params
        a = self.av_count / self.count if self.count != 0 else 0
        e = avgain(network.g, network.br, network.ba, network.n, a)
        capacity = self.capacity / (1 - a * e)
        tt = traveltime(self.count, self.freeflow, capacity)
        return tt

    def __str__(self):
        return f'Road({self.start}->{self.end})'

    __repr__ = __str__


# Network: Built from a list of roads
class Network:
    """ Indexes roads by order in init list
    """

    def __init__(self, roads, ba=0.9, br=1.2, g=0.75, n=5):
        self.roadlist = roads
        self.nroads = len(self.roadlist)
        self.ba = ba
        self.br = br
        self.g = g
        self.n = n

    def display(self):
        # Pandas DataFrames are human readable so
        db = pd.DataFrame(self.roadlist, columns=["Road"])
        db['Origin'] = [road.start for road in self.roadlist]
        db['Destination'] = [road.end for road in self.roadlist]
        db['Capacity'] = [road.capacity for road in self.roadlist]
        db['Free Flow'] = [road.freeflow for road in self.roadlist]
        db['Count'] = [road.count for road in self.roadlist]
        db['TT'] = [road.tt(self) for road in self.roadlist]
        return db

    # path finding alg
    def routes(self, origin, destination):
        routes = []
        # Starting roads
        explore = [road for road in self.roadlist if road.start == origin]
        # check if start roads reach destination
        closed = [[road] for road in explore if road.end == destination]
        routes = routes + closed
        # Open for exploration, looped until done
        opn = [road for road in explore if road not in closed]
        explore = []
        for entry in opn:
            next = [[entry, road] for road in self.roadlist if road.start == entry.end]
            explore = explore + next
        while len(explore) > 0:
            for path in explore:
                explore = [entry for entry in explore if entry is not path]
                end_road = path[-1]
                end_explore = [road for road in self.roadlist if road.start == end_road.end]
                closed = [path + [road] for road in end_explore if road.end == destination]
                routes = routes + closed
                opn = [path + [road] for road in end_explore if road not in closed]
                explore = explore + opn
        return routes

    # Road to index type change
    def index(self, road):
        index = self.roadlist.index(road)
        return index

    def update(self, drivers):
        for road in self.roadlist:
            count = 0
            av_count = 0
            for driver in drivers:
                if road in driver.route:
                    count += 1
                    if driver.type == 'AV':
                        av_count += 1
            road.count = count
            road.av_count = av_count


if __name__ == '__main__':
    roads = [Road('1', '12', 1000, .02), Road('1', '5', 1000, .02), Road('4', '5', 1000, .02),
             Road('4', '9', 1000, .02), Road('5', '9', 1000, .02), Road('5', '6', 1000, .02),
             Road('9', '10', 1000, .02), Road('9', '13', 1000, .02),
             Road('6', '7', 1000, .02), Road('12', '8', 1000, .02), Road('10', '11', 1000, .02),
             Road('13', '3', 1000, .02), Road('12', '6', 1000, .02), Road('6', '10', 1000, .02),
             Road('7', '11', 1000, .02), Road('7', '18', 1000, .02), Road('11', '2', 1000, .02),
             Road('11', '3', 1000, .02), Road('8', '2', 1000, .02)]
    network = Network(roads)
    print(network.routes('1', '2'))
