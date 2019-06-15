import * as express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import * as url from "url"
import { User } from './userObj';
import { addUser, init, login, addFriend, getFriendList, searchPeople } from './user';
import { MessageQueue, Member, Message, createNewMember } from './chat/chat';


const app = express();
app.use(express.json())
//initialize a simple http server
const server = http.createServer(app);
//initialize the WebSocket server instance
const wss = new WebSocket.Server({ server: server, path: "" });
// Message queue
const messageQueue = new MessageQueue()
// Members
let members: Member[] = []


wss.on('connection', async (ws: WebSocket, req) => {
    let userID = ""
    if (req.url) {
        try{
            userID = url.parse(req.url, true).query.userID.toString()
            let member = createNewMember(userID, members)
            member.addClient(ws)
            if(!members.includes(member)){
                console.log("Connecting user", userID)
                members.push(member)
                console.log("Number of online user", members.length)
            }
            while (await messageQueue.hasMessage(member.userId)) {
                let message = await messageQueue.getMessage(member.userId)
                member.send(message)
            }
        } catch(err){
            console.error(err);
        }
    }

    ws.on("close", () => {
        console.log("Connection close")
        for (let [i, member] of members.entries()) {
            if (member.userId === userID) {
                members.splice(i, 1)
                break
            }
        }
    })

    ws.on('message', (msg: string) => {
        let message: Message = JSON.parse(msg)
        let sent = false
        for (let member of members) {
            console.log(member.userId, message.receiver)
            if (member.userId === message.receiver) {
                if (member.websocket) {
                    member.websocket.send(JSON.stringify(message))
                    console.log("Sent message")
                    sent = true
                    break
                }
            }
        }
        if (!sent) {
            messageQueue.addMessage(message)
            console.log("Receiver not online")
        }
        let ret: Message = { 
            receiver: message.sender, 
            receiverName: message.receiver,
            sender: message.receiver, 
            messageBody: message.messageBody + " ok", 
            time: message.time 
        }

        ws.send(JSON.stringify(ret))
    });
});

app.get("/", (req, res) => {
    res.send("Hello world a")
})

app.post("/add/user", async (req, res) => {
    let user: User = req.body
    try {
        if (user.userName && user.password) {
            await init()
            let uid = await addUser(user)
            res.send({ userId: uid })
        } else {
            res.send({ err: "Data not vaild" })
        }

    } catch (err) {
        res.status(400).send({ err: err })
    }

})

app.post("/login", async (req, res) => {
    let userName: string = req.body.userName
    let password: string = req.body.password
    try {
        let uid = await login(userName, password)
        console.log("Login")
        res.send({ userId: uid })
    } catch (err) {
        console.log(err)
        res.status(400).send({ err: err })
    }
})

app.post("/add/friend", async (req, res) => {
    console.log(req.body)
    let user: User = req.body.user
    let friend: User = req.body.friend
    try {
        let status = await addFriend(user, friend)
        res.send({ status: status })
    } catch (err) {
        res.status(400).send({ err: err })
    }
})

app.get("/get/friends", async (req, res) => {
    let userID: string = req.query.userID
    try {
        let list: User[] = await getFriendList({ _id: userID })
        res.send(list)
    } catch (err) {
        res.send([])
    }
})

app.get("/search/user", async (req, res) => {
    let userName: string = req.query.userName
    try {
        let userList = await searchPeople(userName)
        res.send(userList)
    } catch (err) {
        res.send({ err: err })
    }
})

app.get("/test", async (req, res) =>{
    res.send("ok")
})

//start our server
server.listen(8000, () => {
    console.log(`server start`);
});