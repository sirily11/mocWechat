import json
import asyncio
from quart import Quart, render_template, request, websocket
# import websockets
# from flask import Flask, render_template
from contact import User, App

app = Quart(__name__)
databaseApp = App()

connected = {}


# app = Flask(__name__)

@app.route("/home")
def home():
    current_user = request.args.get('current_user')
    room_info = User(user_id=current_user, image_url="").get_chatrooms()
    print(room_info)
    return render_template("home.html", title="Message", chatroom=room_info,
                           current_user=current_user, show_addbtn=True)


@app.route('/')
async def login():
    return await render_template("login.html")


@app.route("/sign_up")
def sign_up():
    user_id = request.args.get('user_id')
    password = request.args.get('password')
    success, message = User.signup(user_id=user_id, password=password)
    return json.dumps({
        "success": success,
        "message": message
    })


@app.route("/check_login")
def login_handler():
    user_id = request.args.get('user_id')
    password = request.args.get('password')
    success, msg = User.login(user_id=user_id, password=password)
    return json.dumps({
        "success": success,
        "message": msg
    })


@app.websocket('/search')
async def searching_handler():
    while True:
        user_input = await websocket.receive()
        result = User.search(user_id=user_input)
        await websocket.send(json.dumps(result))


@app.route("/add")
def add_handler():
    from_user = request.args.get('from_user')
    to_user = request.args.get('to_user')
    user = User(user_id=from_user, image_url="").with_message("Hi").to(to_user).send()
    print(from_user)
    return {"success": True}


@app.route("/chatroom", methods=["GET", "POST"])
async def chatroom():
    from_user = request.args.get('from_user')
    to_user = request.args.get('to_user')
    room_id = request.args.get('room_id')
    User(user_id=from_user, image_url="some.img")
    messages = User.get_message(room_id)
    return await render_template("chatroom.html",
                                 title=to_user, from_user=from_user, to_user=to_user,
                                 show_backarr=True, messages=messages, room_id=room_id)


@app.websocket('/ws/<room_id>/<from_user>/<to_user>')
async def ws(room_id, from_user, to_user):
    # Store the connection
    connected.update({
        room_id + from_user: websocket._get_current_object()
    })
    while True:
        # get the data
        data = await websocket.receive()
        # parse the data
        data = json.loads(data)
        # create a user object
        user = User(user_id=from_user, image_url="some.img")
        # write the data to database
        user.with_message(data['message']).to(to_user).send()
        try:
            # use the websocket in the same room and send the message
            soc = connected[room_id + to_user]
            await soc.send(data["message"])
        except Exception as e:
            print(e)


if __name__ == "__main__":
    databaseApp.start()
    ip = "0.0.0.0"
    # start_server = websockets.serve(ws, ip, 5678)
    # loop = asyncio.get_event_loop()
    # loop.run_until_complete(start_server)
    app.run("0.0.0.0", port=5000, debug=True)
    # asyncio.get_event_loop().run_forever()
