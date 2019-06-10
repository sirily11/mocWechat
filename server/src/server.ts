import * as express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import { User } from './userObj';
import { addUser, init, login, addFriend, getFriendList, searchPeople } from './user';

const app = express();
app.use(express.json())

//initialize a simple http server
const server = http.createServer(app);

//initialize the WebSocket server instance
const wss = new WebSocket.Server({ server: server, path: "/hello" });

wss.on('connection', (ws: WebSocket) => {
    ws.on('message', (message: string) => {
        console.log('received: %s', message);
        ws.send(`Hello, you sent -> ${message}`);
    });
    ws.send('Hi there, I am a WebSocket server');
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
        res.send({ err: err })
    }
    console.log(req.query)
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

//start our server
server.listen(8000, () => {
    console.log(`server start`);
});