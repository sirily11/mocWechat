import json
from quart import Quart, render_template, websocket
# from flask import Flask, render_template
from contact import User

app = Quart(__name__)
# app = Flask(__name__)


def init():
    pass


@app.route("/")
def home():
    return render_template("home.html")


@app.route('/get_contacts')
async def get_contacts():
    return json.dumps(init())


@app.route("/chatroom/<user_name>")
def chatroom(user_name):
    from_user = "sirilee"
    return render_template("chatroom.html",
                           title=user_name, from_user=from_user, to_user=user_name)


@app.websocket('/ws')
async def ws():
    while True:
        data = await websocket.receive()
        data = json.loads(data)
        user = User(user_id=data['from'], image_url="some.img").create_table().write_to_database()
        user.with_message(data['message']).to(data['to']).send()
        # await websocket.send(f"echo {data}")


if __name__ == "__main__":
    app.run('0.0.0.0', port=5000, debug=True)
