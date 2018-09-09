from contact import User, Message, Contact, App
import pytest


def test_send():
    user = User("testid", "someimg.jpg")
    json = user.with_message("hello").to("testid2").send(write=False).message.to_json()
    assert json['Sender'] == "testid"
    assert json["Receiver"] == "testid2"
    assert json["Content"] == "hello"


def test_send():
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