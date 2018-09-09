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
        c.execute("UPDATE contact SET last_message = ?,number_of_unread=?", (self.content, self.number_of_unread))
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
        self.message = Message(self.id, self.room_owner, self.friend, msg).create_table()
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
                          room_owner=self.user_id).create_table().create_message(self.message)
        if write:
            contact.write_to_database()

        return contact

    def write_to_database(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = (self.user_id, self.image_url)
        c.execute("Insert OR IGNORE INTO user VALUES (?,?)", data)
        conn.commit()
        return self

    def get_contacts(self):
        try:
            conn = sqlite3.connect('mock_Wechat.db')
            c = conn.cursor()
            chatroom = c.execute("SELECT id,sender_id FROM contact where receiver_id=?", (self.user_id,)).fetchall()
            for chat in chatroom:
                self.room_id, sender_id = chat
                user_image, = c.execute("SELECT image_url FROM user where user_id=?", (sender_id,)).fetchall()[0]
                # print(user_image)
                print("Chatting in the room: " + self.room_id)
        except Exception as e:
            pass
        return self


class App:
    def __init__(self):
        pass

    def start(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        # Create user table
        c.execute("""CREATE TABLE IF NOT EXISTS user
                (user_id text,image_url text, UNIQUE (user_id))""")
        # Create Contact table
        c.execute("""CREATE TABLE IF NOT EXISTS contact 
                                     (id TEXT, name text, room_owner text, friend text ,
                                     last_message text, number_of_unread text,UNIQUE (id)) 
                                     """)
        # Create Message table
        c.execute("""CREATE TABLE IF NOT EXISTS message 
                                   (id TEXT, time text, sender text, receiver text, content text, read text)""")

# user = User(user_id="sirilee", image_url="some.jpg")
# user.create_table().write_to_database()
#
# user1 = User(user_id="sirily", image_url="some1.jpg")
# user1.write_to_database()
# index = 0
# while True:
#     message = input("Message: ")
#     if index % 2 == 0:
#         print("From sirily to sirilee")
#         user1.to("sirilee").with_message(message).send()
#     else:
#         print("From sirilee to sirily")
#         user.to("sirily").with_message(message).send()
#     index += 1
