import flask
import socket
from flask import request, jsonify

app = flask.Flask(__name__)
app.config["DEBUG"] = True


@app.route('/', methods=['GET'])
def home():
    return '''Hello example'''

@app.route('/greetings', methods=['GET'])
def greetings():
    return '''Hello World from '''+socket.gethostname()


@app.route('/square', methods=['GET'])
def square():
    if 'x' in request.args:
        x = int(request.args['x'])
    else:
        return "Error: No id field provided. Please specify an correct number for X"
    y=x**2
    return f'{y}'

app.run()