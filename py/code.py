import json
import numpy
from igraph import *
import matplotlib.pyplot as plt
from math import log
import os
from collections import deque

def createGraph(json_address):
    #print(json_address)
    f = open('../datas/' + json_address, 'r', errors='ignore')
    strData = f.read()

    data = json.loads(strData)

    metabolites = {}
    for metabolite in data['metabolites']:
        metabolites[metabolite['id']] = {
                'links': []
                }

    for reaction in data['reactions']:
        reactants = []
        products = []
        for metabolite in reaction['metabolites']:
            coef = reaction['metabolites'][metabolite]
            if coef > 0:
                products.append(metabolite)
            else:
                reactants.append(metabolite)

        for metabolite in reaction['metabolites']:
            coef = reaction['metabolites'][metabolite]
            if coef > 0:
                for reactant in reactants:
                    metabolites[reactant]['links'].extend(products)

    # generate vertices
    vertices = list( metabolites.keys() )
    # print(vertices)

    # generate links
    links = []
    for metabolite in metabolites:
        links.extend(list( map(lambda x: (metabolite, x), metabolites[metabolite]['links']) ) )
    # print(links)

    g = Graph(directed=True)
    g.add_vertices(vertices)
    g.add_edges(links)
    
    return g

# generate degrees
def histGraph(g):
    degrees = g.vs.degree()
    #print(degrees)
    degrees_log = [log(degree + 1) for degree in degrees]

#    plt.hist(degrees_log, log=True, alpha=0.5)
    
    y,binEdges=numpy.histogram(degrees_log,bins=10)
    bincenters = 0.5*(binEdges[1:]+binEdges[:-1])
    
    plt.plot(bincenters, numpy.log(y))
    plt.title("Degree Distribution")
    plt.xlabel("Degree")
    plt.ylabel("Frequency")

def bfs(graph, source):
    n = len(graph.vs.degree())

    dist = [-1] * n
    dist[source] = 0
    
    bfs_deque = deque([source])
    while(len(bfs_deque)):
        v = bfs_deque.popleft()
        for u in graph.vs.find(v).neighbors():
            if dist[u.index] == -1:
                dist[u.index] = dist[v] + 1
                bfs_deque.append(u.index)
    return dist

def histDistance(graph):
    n = len(graph.vs.degree())
    hist = [0] * n;
    for ind in range(0, n):
        dist = bfs(graph, ind)
        for d in dist:
            if not d == -1:
                hist[d] = hist[d] + 1
    hist = [x / (n*n) for x in hist]
    plt.plot(range(0, 9), hist[0:9])
    print(hist)

for file_addr in os.listdir('../datas/'):
    if not file_addr.startswith('.'):
        g = createGraph(file_addr)
        #histGraph(g)
        #print("start hist distance: " + file_addr)
        histDistance(g)

plt.show()
