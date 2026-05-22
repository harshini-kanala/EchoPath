import networkx as nx


def shortest_path(graph, start, destination):
    path = nx.dijkstra_path(graph,
                            source=start,
                            target=destination,
                            weight='weight')

    return path