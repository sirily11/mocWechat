import datetime
import sqlite3
import uuid

from passlib.hash import pbkdf2_sha256


class Message:
    def __init__(self, room_id, sender, receiver, content, read=False):
        self.time = str(datetime.datetime.now())
        self.sender = sender
        self.receiver = receiver
        self.content = content
        self.read = read
        self.number_of_unread = 0
        self.id = room_id

    def __set_time__(self, new_time):
        self.time = new_time
        return self

    def write_to_database(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = (self.id, self.time, self.sender, self.receiver, self.content, str(self.read))
        number_of_unread = c.execute("SELECT read FROM message WHERE id=? AND read=?", (self.id, "False")).fetchall()
        self.number_of_unread = len(number_of_unread) + 1
        c.execute("INSERT INTO message VALUES (?,?,?,?,?,?)", data)
        c.execute("UPDATE contact SET last_message = ?,number_of_unread=? WHERE id=?",
                  (self.content, self.number_of_unread, self.id))
        conn.commit()
        return self

    def to_json(self):
        json_str = {
            "Room id": self.id,
            "Time": self.time,
            "Sender": self.sender,
            "Receiver": self.receiver,
            "Content": self.content,
            "Read": self.read,
            "Number of unread": self.number_of_unread
        }
        return json_str


class Contact:
    def __init__(self, room_id, name, friend, room_owner):
        self.room_owner = room_owner
        self.name = name
        self.friend = friend
        self.last_message = ""
        self.number_unread = ""
        self.message = None
        self.id = room_id

    def create_message(self, msg: str, address=""):
        self.message = Message(self.id, self.room_owner, self.friend, msg)
        return self

    def write_to_database(self, exist):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = (self.id, self.name, self.room_owner, self.friend, self.last_message, self.number_unread)
        data2 = (self.id, self.name, self.friend, self.room_owner, self.last_message, self.number_unread)
        if not exist:
            c.execute("INSERT INTO contact VALUES (?,?,?,?,?,?)", data)
            c.execute("INSERT INTO contact VALUES (?,?,?,?,?,?)", data2)
        conn.commit()
        self.message.write_to_database()
        return self

    def to_json(self):
        json_str = {
            "Name": self.name,
            "User id": self.friend,
            "Last message": self.last_message,
        }
        return json_str


class User:
    def __init__(self, user_id, image_url):
        self.user_id = user_id
        self.image_url = image_url
        self.contact = []
        self.room_id = None
        self.receiver = None
        self.message = None

    def to(self, person):
        self.receiver = person
        return self

    def with_message(self, msg):
        self.message = msg

        return self

    def __search_room_id__(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = c.execute("SELECT id FROM contact WHERE room_owner=? AND friend=?",
                         (self.user_id, self.receiver)).fetchall()
        if len(data) > 0:
            room_id, = data[0]
            return room_id

    def read(self, room_id):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        c.execute("UPDATE contact SET number_of_unread=? WHERE id=? AND room_owner=?",
                  (0, room_id, self.user_id))
        c.execute("UPDATE message SET read=? WHERE id=? AND receiver=?",
                  ("True", room_id, self.user_id))
        conn.commit()

    def send(self, write=True):
        exist = self.__search_room_id__()
        if self.receiver is None:
            raise Exception("No receive defined, use to() before send")
        if exist:
            # if the room already exist
            uu = exist
        else:
            uu = str(uuid.uuid3(uuid.NAMESPACE_DNS, self.user_id + self.receiver))

        contact = Contact(room_id=uu, name=self.receiver, friend=self.receiver,
                          room_owner=self.user_id).create_message(self.message)
        if write:
            # if the room already exist, then pass the exist parm
            contact.write_to_database(exist)

        return contact

    @staticmethod
    def login(user_id, password):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = c.execute("SELECT password FROM user WHERE user_id =?", (user_id,)).fetchall()
        if len(data) > 0:
            psw, = data[0]
            if pbkdf2_sha256.verify(password, psw):
                return True, "success"
            else:
                return False, "password"
        else:
            return False, "user_id"

    @staticmethod
    def signup(user_id, password):
        password = pbkdf2_sha256.hash(password)
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        try:
            c.execute("INSERT INTO user VALUES (?,?,?)", (user_id, "", password))
            conn.commit()
            return True, "success"
        except Exception as e:
            return False, "User already exists"

    @staticmethod
    def search(user_id):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = c.execute("SELECT user_id,image_url FROM user WHERE user_id LIKE '%{}%'".format(user_id)).fetchall()
        li = []
        for d in data:
            uid, img = d
            li.append({
                "user_id": uid,
                "image": img
            })
        return li

    def write_to_database(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = (self.user_id, self.image_url)
        c.execute("INSERT OR IGNORE INTO user VALUES (?,?,?)", data)
        conn.commit()
        return self

    def get_chat_room(self):
        li = []
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        chat_room = c.execute("SELECT * FROM contact WHERE room_owner=?", (self.user_id,)).fetchall()

        for c in chat_room:
            room_id, name, room_owner, friend, last_message, number_unread = c
            li.append({
                "room_id": room_id,
                "name": name,
                "room_owner": room_owner,
                "friend": friend,
                "last_message": last_message,
                "number_unread": number_unread
            })
        return li

    @staticmethod
    def get_message(room_id):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        messages = c.execute("SELECT content,sender,receiver FROM message WHERE id=?", (room_id,)).fetchall()
        li = []
        for message in messages:
            content, sender, receiver = message
            li.append({
                "content": content,
                "sender": sender,
                "receiver": receiver
            })
        return li

    @staticmethod
    def mark_as_read(room_id, user_id):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        c.execute("UPDATE contact SET number_of_unread=?")


class App:
    def __init__(self, database_name="mock_Wechat.db"):
        self.database_name = database_name

    @staticmethod
    def remove_user(user_id):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        c.execute("DELETE FROM user WHERE user_id=?", (user_id,))
        conn.commit()

    @staticmethod
    def remove_contact(room_id):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        c.execute("DELETE FROM contact WHERE id=?", (room_id,))
        c.execute("DELETE FROM message WHERE id=?", (room_id,))
        conn.commit()

    def start(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        # Create user table
        c.execute("""CREATE TABLE IF NOT EXISTS user
                (user_id TEXT,image_url TEXT, password TEXT, UNIQUE (user_id))""")
        # Create Contact table
        c.execute("""CREATE TABLE IF NOT EXISTS contact 
                                     (id TEXT, name TEXT, room_owner TEXT, friend TEXT ,
                                     last_message TEXT, number_of_unread TEXT) 
                                     """)
        # Create Message table
        c.execute("""CREATE TABLE IF NOT EXISTS message 
                                   (id TEXT, time TEXT, sender TEXT, receiver TEXT, content TEXT, read TEXT)""")
        return self
