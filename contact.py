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
        self.id = room_id

    def __set_time__(self, new_time):
        self.time = new_time
        return self

    def create_table(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        c.execute("""CREATE TABLE IF NOT EXISTS message 
                            (id TEXT, time text, sender text, receiver text, content text, read text)""")
        return self

    def write_to_database(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = (self.id, self.time, self.sender, self.receiver, self.content, str(self.read))
        c.execute("INSERT INTO message VALUES (?,?,?,?,?,?)", data)
        c.execute("UPDATE contact SET last_message = ?",(self.content,))
        conn.commit()
        return self

    def to_json(self):
        json_str = {
            "Time": self.time,
            "Sender": self.sender,
            "Receiver": self.receiver,
            "Content": self.content,
            "Read": self.read
        }
        return json_str


class Contact:
    def __init__(self, room_id, img, name, receiver_id, sender_id):
        self.sender_id = sender_id
        self.img = img
        self.name = name
        self.receiver_id = receiver_id
        self.last_message = ""
        self.number_unread = ""
        self.id = room_id

    def create_table(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        c.execute("""CREATE TABLE IF NOT EXISTS contact 
                             (id TEXT, name text, sender_id text, receiver_id text ,
                             last_message text, number_of_unread text,UNIQUE (id) 
                             FOREIGN KEY(id) REFERENCES message(id))""")
        return self

    def send_message(self, msg: str):
        message = Message(self.id, self.sender_id, self.receiver_id, msg)
        message.create_table().write_to_database()
        return self

    def write_to_database(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = (self.id, self.name, self.sender_id, self.receiver_id, self.last_message, self.number_unread)
        c.execute("INSERT OR IGNORE INTO contact VALUES (?,?,?,?,?,?)", data)
        conn.commit()
        return self

    def to_json(self):
        json_str = {
            "Img": self.img,
            "Name": self.name,
            "User id": self.receiver_id,
            "Last message": self.last_message,
            "Unread": self.number_unread
        }
        return json_str


class User:
    def __init__(self, user_id, image_url):
        self.user_id = user_id
        self.image_url = image_url
        self.contact = []

    def new_chatroom(self,to,msg):
        uu = str(uuid.uuid3(uuid.NAMESPACE_DNS, self.user_id+to))
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        img_url, = c.execute("SELECT image_url FROM user where user_id=?", (to,)).fetchall()[0]
        contact = Contact(room_id=uu,img=img_url,name=to,receiver_id=to,
                          sender_id=self.user_id).create_table().send_message(msg).write_to_database()

        return self


    def create_table(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        c.execute("""CREATE TABLE IF NOT EXISTS user
        (user_id text,image_url text, UNIQUE (user_id))""")
        return self

    def write_to_database(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        data = (self.user_id, self.image_url)
        c.execute("Insert OR IGNORE INTO user VALUES (?,?)", data)
        conn.commit()
        return self

    def get_contacts(self):
        conn = sqlite3.connect('mock_Wechat.db')
        c = conn.cursor()
        chatroom = c.execute("SELECT id,sender_id FROM contact where receiver_id=?", (self.user_id,)).fetchall()
        for chat in chatroom:
            room_id, sender_id = chat
            user_image, = c.execute("SELECT image_url FROM user where user_id=?", (sender_id,)).fetchall()[0]
            print(user_image)
            print(room_id, sender_id)
        return self


# user = User(user_id="sirilee", image_url="some.jpg")
# user.create_table().write_to_database()
#
# user1 = User(user_id="sirily", image_url="some1.jpg")
# user1.write_to_database()
#
# while True:
#     message = input("Message: ")
#     user.new_chatroom(to="sirily",msg=message)