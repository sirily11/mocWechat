import json
import asyncio
from quart import Quart, render_template, request, websocket
from contact import User, App

app = Quart(__name__)
databaseApp = App()
# a dict to memorized all the connected websockets
connected = {}


@app.route("/home")
async def home():
    current_user = request.args.get('current_user')
    room_info = User(user_id=current_user, image_url="").get_chat_room()

    return await render_template("home.html", title="Message", chatroom=room_info,
                                 current_user=current_user, show_addbtn=True)


@app.route('/')
async def login():
    return await render_template("login.html")


# a handler for signing up
@app.route("/sign_up")
def sign_up_handler():
    user_id = request.args.get('user_id')
    password = request.args.get('password')
    success, message = User.signup(user_id=user_id, password=password)
    return json.dumps({
        "success": success,
        "message": message
    })


# a handler for checking login
@app.route("/check_login")
def login_handler():
    user_id = request.args.get('user_id')
    password = request.args.get('password')
    success, msg = User.login(user_id=user_id, password=password)
    return json.dumps({
        "success": success,
        "message": msg
    })


# a handler for searching function
# which will have a auto notification of the user
# which have a similar user id
@app.websocket('/search')
async def searching_handler():
    while True:
        user_input = await websocket.receive()
        result = User.search(user_id=user_input)
        await websocket.send(json.dumps(result))


# a handler for adding new chat room
@app.route("/add")
def add_handler():
    from_user = request.args.get('from_user')
    to_user = request.args.get('to_user')
    user = User(user_id=from_user, image_url="").with_message("Hi").to(to_user).send()
    print(from_user)
    return {"success": True}


# chat room
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


# websocket for chatting
@app.websocket('/ws/<room_id>/<from_user>/<to_user>')
async def ws(room_id, from_user, to_user):
    # Store the connection
    connected.update({
        room_id + from_user: websocket._get_current_object()
    })
    # create a user object
    user = User(user_id=from_user, image_url="some.img")
    user.read(room_id)
    while True:
        # get the data
        data = await websocket.receive()
        # parse the data
        data = json.loads(data)
        # write the data to database
        user.with_message(data['message']).to(to_user).send()
        user.read(room_id=room_id)
        try:
            # use the websocket in the same room and send the message
            soc = connected[room_id + to_user]
            await soc.send(data["message"])
        except Exception as e:
            print(e)


def run(ip, port):
    asyncio.set_event_loop(asyncio.new_event_loop())
    databaseApp.start()
    app.run(ip, port=port)


def stop():
    func = request.environ.get('werkzeug.server.shutdown')
    if func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    func()
