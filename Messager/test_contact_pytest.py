import sqlite3

from .messager import User, App


def test_send():
    user = User("testid", "someimg.jpg")
    json = user.with_message("hello").to("testid2").send(write=False).message.to_json()
    assert json['Sender'] == "testid"
    assert json["Receiver"] == "testid2"
    assert json["Content"] == "hello"


def test_send2():
    user = User("testid", "someimg.jpg")
    json = user.with_message("你好").to("testid2").send(write=False).message.to_json()
    assert json['Sender'] == "testid"
    assert json["Receiver"] == "testid2"
    assert json["Content"] == "你好"


def test_sign_up():
    # signup
    user_id = "test1"
    password = "1234"
    success, message = User.signup(user_id=user_id, password=password)
    assert success == True
    assert message == "success"
    App.remove_user(user_id=user_id)


def test_sign_up2():
    # signup with same user id
    user_id = "test1"
    password = "1234"
    User.signup(user_id=user_id, password=password)
    success, message = User.signup(user_id=user_id, password=password)
    assert success == False
    assert message == "User already exists"
    App.remove_user(user_id=user_id)


def test_login():
    # no such user test
    user_id = "test1"
    password = "1234"
    success, message = User.login(user_id=user_id, password=password)
    assert success == False
    assert message == "user_id"


def test_login2():
    # wrong password
    user_id = "test1"
    password = "1234"
    # sign up the user first
    User.signup(user_id=user_id, password=password)
    # wrong password
    success, message = User.login(user_id=user_id, password="123")
    assert success == False
    assert message == "password"
    App.remove_user(user_id=user_id)


def test_login3():
    # successfully login
    user_id = "test1"
    password = "1234"
    # sign up the user first
    User.signup(user_id=user_id, password=password)
    # wrong password
    success, message = User.login(user_id=user_id, password=password)
    assert success == True
    assert message == "success"
    App.remove_user(user_id=user_id)


def test_search():
    # search similar
    user_id = "test1"
    user_id2 = "tesst2"
    password = "1234"
    User.signup(user_id=user_id, password=password)
    User.signup(user_id=user_id2, password=password)
    result = User.search("te")
    assert len(result) == 2
    App.remove_user(user_id=user_id)
    App.remove_user(user_id=user_id2)


def test_send_msg():
    user_id = "test1"
    user_id2 = "tesst2"
    password = "1234"
    # first sign up both user
    User.signup(user_id=user_id, password=password)
    User.signup(user_id=user_id2, password=password)
    # then create a user object
    user1 = User(user_id, "")
    user1.with_message("Hello").to(user_id2).send()
    room_id = user1.__search_room_id__()
    # now select the id in contact table, the length should be 2
    conn = sqlite3.connect('mock_Wechat.db')
    c = conn.cursor()
    data = c.execute("SELECT room_owner,friend,last_message from contact where id=?", (room_id,)).fetchall()
    App.remove_contact(room_id)
    App.remove_user(user_id=user_id)
    App.remove_user(user_id=user_id2)
    assert len(data) == 2
    room_owner, friend, last_message = data[0]
    assert last_message == "Hello"
    assert room_owner == user_id
    assert friend == user_id2

    room_owner, friend, last_message = data[1]
    assert last_message == "Hello"
    assert room_owner == user_id2
    assert friend == user_id


def test_send_msg2():
    # test with the insert into contact table
    user_id = "test1"
    user_id2 = "tesst2"
    password = "1234"
    # first sign up both user
    User.signup(user_id=user_id, password=password)
    User.signup(user_id=user_id2, password=password)
    # then create a user object
    user1 = User(user_id, "")
    user1.with_message("Hello").to(user_id2).send()
    user1.with_message("Hello").to(user_id2).send()
    room_id = user1.__search_room_id__()
    # now select the id in contact table, the length should be 2
    conn = sqlite3.connect('mock_Wechat.db')
    c = conn.cursor()
    data = c.execute("SELECT room_owner,friend,last_message from contact where id=?", (room_id,)).fetchall()
    App.remove_contact(room_id)
    App.remove_user(user_id=user_id)
    App.remove_user(user_id=user_id2)
    assert len(data) == 2
    room_owner, friend, last_message = data[0]
    assert last_message == "Hello"
    assert room_owner == user_id
    assert friend == user_id2

    room_owner, friend, last_message = data[1]
    assert last_message == "Hello"
    assert room_owner == user_id2
    assert friend == user_id


def test_read():
    # test with the insert into contact table
    user_id = "test1"
    user_id2 = "tesst2"
    password = "1234"
    # first sign up both user
    User.signup(user_id=user_id, password=password)
    User.signup(user_id=user_id2, password=password)
    # then create a user object
    user1 = User(user_id, "")
    user2 = User(user_id2, "")
    user1.with_message("Hello").to(user_id2).send()
    user1.with_message("Hello").to(user_id2).send()
    room_id = user1.__search_room_id__()
    number_unread_old = int(user2.get_chat_room()[0]["number_unread"])
    user2.read(room_id)
    number_unread_new = int(user2.get_chat_room()[0]["number_unread"])
    App.remove_contact(room_id)
    App.remove_user(user_id=user_id)
    App.remove_user(user_id=user_id2)
    assert number_unread_old == 2
    assert number_unread_new == 0
