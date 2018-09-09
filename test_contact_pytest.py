from contact import User, Message, Contact
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
