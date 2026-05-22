import networkx as nx

def load_graph():

    G = nx.Graph()

    # -------- SMART CONNECTIONS -------- #

    G.add_edge(
        "Entrance",
        "Reception",
        weight=2,
        instruction="Walk straight towards Reception"
    )

    G.add_edge(
        "Reception",
        "Emergency",
        weight=2,
        instruction="Turn left towards Emergency"
    )

    G.add_edge(
        "Emergency",
        "Corridor",
        weight=2,
        instruction="Walk straight through the corridor"
    )

    G.add_edge(
        "Corridor",
        "Radiology",
        weight=2,
        instruction="Radiology is ahead on your right"
    )

    G.add_edge(
        "Reception",
        "Waiting Area",
        weight=2,
        instruction="Walk forward to Waiting Area"
    )

    G.add_edge(
        "Waiting Area",
        "Ward",
        weight=2,
        instruction="Move straight towards Ward"
    )

    G.add_edge(
        "Ward",
        "Cafeteria",
        weight=2,
        instruction="Cafeteria is next to Ward"
    )

    coordinates = {

        "Entrance": (500, 720),
        "Reception": (350, 600),
        "Emergency": (120, 380),
        "Corridor": (400, 300),
        "Radiology": (520, 120),
        "Waiting Area": (650, 600),
        "Ward": (850, 380),
        "Cafeteria": (900, 600)

    }

    return G, coordinates