import json

# from quart import Quart, render_template, websocket
from flask import Flask, render_template

from contact import Contact, Message

# app = Quart(__name__)
app = Flask(__name__)


def init():
    img = "https://pm1.narvii.com/6030/6a1748ff89573ebd63cec56838c2dd732e1bb08e_hq.jpg"
    msg1 = Message(room_id="123",sender="P1", receiver="P2", content="Hello there")
    msg2 = Message(room_id="123",sender="P2", receiver="P3", content="What's going on")

    return [person.to_json(), person2.to_json()]


@app.route("/")
def home():
    return render_template("home.html", messages=init())


@app.route('/get_contacts')
async def get_contacts():
    return json.dumps(init())


if __name__ == "__main__":
    app.run('0.0.0.0', port=5000, debug=True)
