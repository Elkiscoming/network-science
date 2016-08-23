import json
import networkx as nx
# import igraph as ig
import plotly.plotly as py
from plotly.graph_objs import *

f = open('iECW_1372.json', 'r')
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

# generate degrees
degrees = list(map( lambda x: len(x['links']), list(metabolites.values()) ))
# print(degrees)

# generate vertices
vertices = list( metabolites.keys() )
# print(vertices)

# generate links
links = []
for metabolite in metabolites:
    links.extend(list( map(lambda x: (metabolite, x), metabolites[metabolite]['links']) ) )
# print(links)

# igraph code
## g = ig.Graph(directed=True)
## g.add_vertices(vertices)
## g.add_edges(links)
##
## layout = g.layout("kk")
## plot(g, layout = layout)

data = [
        Histogram(x=degrees)
        ]
py.plot(data)
'''
g=nx.DiGraph()
g.add_nodes_from(vertices)
g.add_edges_from(links)

pos=nx.fruchterman_reingold_layout(g)

axis=dict(showline=False, # hide axis line, grid, ticklabels and  title
          zeroline=False,
          showgrid=False,
          showticklabels=False,
          title='' 
          )

width=800
height=800
layout=Layout(title= "Directed Network of iECW_1372 Escherichia coli W metabolism"+\
              "<br> Data source: <a href='http://bigg.ucsd.edu/models/iECW_1372'> [1]</a>",  
    font= Font(size=12),
    showlegend=False,
    autosize=False,
    width=width,
    height=height,
    xaxis=XAxis(axis),
    yaxis=YAxis(axis),          
    margin=Margin(
        l=40,
        r=40,
        b=85,
        t=100,
    ),
    hovermode='closest',
    annotations=Annotations([
           Annotation(
           showarrow=False, 
            text='This networkx DiGraph has the Kamada-Kawai layout',  
            xref='paper',     
            yref='paper',     
            x=0,  
            y=-0.1,  
            xanchor='left',   
            yanchor='bottom',  
            font=Font(
            size=14 
            )     
            )
        ]),           
    )

Xv=[pos[k][0] for k in vertices]
Yv=[pos[k][1] for k in vertices]
Xed=[]
Yed=[]
for edge in links:
    Xed+=[pos[edge[0]][0],pos[edge[1]][0], None]
    Yed+=[pos[edge[0]][1],pos[edge[1]][1], None] 
    
trace3=Scattergl(x=Xed,
               y=Yed,
               mode='lines',
               line=Line(color='rgb(210,210,210)', width=1),
               hoverinfo='none'
               )
trace4=Scattergl(x=Xv,
               y=Yv,
               mode='markers',
               name='net',
               marker=Marker(symbol='dot',
                             size=5, 
                             color='#6959CD',
                             line=Line(color='rgb(50,50,50)', width=0.5)
                             ),
               text=vertices,
               hoverinfo='text'
               )

annot="This networkx.DiGraph has the Fruchterman-Reingold layout<br>"

data1=Data([trace3, trace4])
fig1=Figure(data=data1, layout=layout)
fig1['layout']['annotations'][0]['text']=annot
py.plot(fig1, filename='directed iECW_1372 metabolism')
'''
