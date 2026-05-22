from flask import Flask, jsonify
from flask_cors import CORS

from modules.graph_builder import load_graph
from modules.pathfinder import shortest_path

app = Flask(__name__)

CORS(app)

hospital_graph, coordinates = load_graph()


@app.route('/navigate/<destination>')
def navigate(destination):

    start = "Entrance"

    destination = destination.title()

    try:

        path = shortest_path(
            hospital_graph,
            start,
            destination
        )

        instructions = []

        for i in range(len(path)-1):

            current_node = path[i]

            next_node = path[i+1]

            edge_data = hospital_graph.get_edge_data(
                current_node,
                next_node
            )

            instructions.append(
                edge_data['instruction']
            )

        return jsonify({

            "success": True,

            "destination": destination,

            "path": path,

            "instructions": instructions

        })

    except Exception as e:

        return jsonify({

            "success": False,

            "error": str(e)

        })


if __name__ == '__main__':

    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )