import datetime
import json
import sqlite3
import uuid


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
        number_of_unread = c.execute("SELECT read from message where id=?", (self.id,)).fetchall()
        self.number_of_unread = len(number_of_unread)
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

    def write_to_database(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = (self.id, self.name, self.room_owner, self.friend, self.last_message, self.number_unread)
        c.execute("INSERT OR IGNORE INTO contact VALUES (?,?,?,?,?,?)", data)
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

    def send(self, write=True, address=""):
        self.get_contacts()
        if self.receiver is None:
            raise Exception("No receive defined, use to() before send")
        if self.room_id:
            uu = self.room_id
        else:
            uu = str(uuid.uuid3(uuid.NAMESPACE_DNS, self.user_id + self.receiver))
        # conn = sqlite3.connect('mock_Wechat.db')
        # c = conn.cursor()
        # img_url, = c.execute("SELECT image_url FROM user where user_id=?", (self.receiver,)).fetchall()[0]
        contact = Contact(room_id=uu, name=self.receiver, friend=self.receiver,
                          room_owner=self.user_id).create_message(self.message)
        if write:
            contact.write_to_database()

        return contact

    @staticmethod
    def login(user_id, password):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = c.execute("SELECT password FROM user where user_id =?", (user_id,)).fetchall()
        if len(data) > 0:
            psw, = data[0]
            if psw == password:
                return True, "success"
            else:
                return False, "password"
        else:
            return False, "user_id"

    @staticmethod
    def signup(user_id, password):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        try:
            c.execute("Insert INTO user VALUES (?,?,?)", (user_id, "", password))
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
        c.execute("Insert OR IGNORE INTO user VALUES (?,?,?)", data)
        conn.commit()
        return self

    def get_contacts(self):
        try:
            conn = sqlite3.connect('mock_Wechat.db')
            c = conn.cursor()
            chatroom = c.execute("SELECT id,room_owner FROM contact where friend=?", (self.user_id,)).fetchall()
            for chat in chatroom:
                self.room_id, sender_id = chat
                user_image, = c.execute("SELECT image_url FROM user where user_id=?", (sender_id,)).fetchall()[0]
        except Exception as e:
            print(e)
        return self

    def get_chatrooms(self):
        l = []
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        chat_room = c.execute("SELECT * FROM contact where room_owner=?", (self.user_id,)).fetchall()
        # if the room owner is not the user
        if len(chat_room) == 0:
            chat_room += c.execute("SELECT * FROM contact where friend=?", (self.user_id,)).fetchall()

        for c in chat_room:
            room_id, name, room_owner, friend, last_message, number_unread = c
            l.append({
                "room_id": room_id,
                "name": name,
                "room_owner": room_owner,
                "friend": friend,
                "last_message": last_message,
                "number_unread": number_unread
            })
        return l

    @staticmethod
    def get_message(room_id):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        messages = c.execute("SELECT content,sender,receiver FROM message where id=?", (room_id,)).fetchall()
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
        c.execute("DELETE FROM user where user_id=?", (user_id,))
        conn.commit()

    def start(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        # Create user table
        c.execute("""CREATE TABLE IF NOT EXISTS user
                (user_id text,image_url text, password text, UNIQUE (user_id))""")
        # Create Contact table
        c.execute("""CREATE TABLE IF NOT EXISTS contact 
                                     (id TEXT, name text, room_owner text, friend text ,
                                     last_message text, number_of_unread text,UNIQUE (id)) 
                                     """)
        # Create Message table
        c.execute("""CREATE TABLE IF NOT EXISTS message 
                                   (id TEXT, time text, sender text, receiver text, content text, read text)""")
        return self
